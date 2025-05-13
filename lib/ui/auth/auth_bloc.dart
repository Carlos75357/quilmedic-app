import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:quilmedic/services/auth_service.dart';
import 'package:quilmedic/ui/auth/auth_event.dart';
import 'package:quilmedic/ui/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription? _authExpirationSubscription;
  Timer? _tokenValidityTimer;
  
  AuthBloc({required AuthService authService}) 
      : _authService = authService,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<TokenExpired>(_onTokenExpired);
    
    _authExpirationSubscription = _authService.onAuthExpired.listen((_) {
      add(TokenExpired());
    });
    
    _startTokenValidityCheck();
  }
  
  void _startTokenValidityCheck() {
    _tokenValidityTimer?.cancel();
    _tokenValidityTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      if (state is Authenticated) {
        final isValid = await _authService.isTokenValid();
        if (!isValid) {
          add(TokenExpired());
        }
      }
    });
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.login(
        event.username,
        event.password,
      );
      
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Error al iniciar sesión'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          final isTokenValid = await _authService.isTokenValid();
          if (isTokenValid) {
            emit(Authenticated(user));
          } else {
            final tokenRenewed = await _authService.handleAuthError();
            if (tokenRenewed) {
              final updatedUser = await _authService.getCurrentUser();
              if (updatedUser != null) {
                emit(Authenticated(updatedUser));
              } else {
                emit(Unauthenticated());
              }
            } else {
              emit(Unauthenticated());
            }
          }
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onTokenExpired(
    TokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout(); 
    
    emit(const AuthError('Sesión expirada. Por favor inicie sesión nuevamente.'));
    
    await Future.delayed(const Duration(seconds: 1));
    
    emit(Unauthenticated());
  }
  
  @override
  Future<void> close() {
    _authExpirationSubscription?.cancel();
    _tokenValidityTimer?.cancel();
    return super.close();
  }
}
