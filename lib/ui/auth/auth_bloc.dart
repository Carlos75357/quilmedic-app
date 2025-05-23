import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:quilmedic/services/auth_service.dart';
import 'package:quilmedic/services/app_version_service.dart';
import 'package:quilmedic/ui/auth/auth_event.dart';
import 'package:quilmedic/ui/auth/auth_state.dart';

/// Bloc que gestiona el estado de autenticación de la aplicación.
/// Maneja eventos relacionados con el inicio de sesión, cierre de sesión
/// y verificación del estado de autenticación.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Servicio de autenticación utilizado para realizar operaciones de login/logout
  final AuthService _authService;
  /// Servicio para verificar actualizaciones de la aplicación
  final AppVersionService _appVersionService = AppVersionService();
  /// Suscripción al stream de eventos de expiración de autenticación
  StreamSubscription? _authExpirationSubscription;
  /// Temporizador para verificar periódicamente la validez del token
  Timer? _tokenValidityTimer;
  
  /// Constructor del AuthBloc
  /// @param [authService] Servicio de autenticación requerido para las operaciones
  AuthBloc({required AuthService authService}) : _authService = authService, super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<TokenExpired>(_onTokenExpired);
    
    _authExpirationSubscription = _authService.onAuthExpired.listen((_) {
      add(TokenExpired());
    });
    
    _startTokenValidityCheck();
  }
  
  /// Inicia una verificación periódica de la validez del token cada 5 minutos
  /// Si el token no es válido, dispara el evento TokenExpired
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

  /// Maneja el evento de solicitud de inicio de sesión
  /// @param [event] Evento con el nombre de usuario y contraseña
  /// @param [emit] Emisor para cambiar el estado de autenticación
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.login(
        event.username,
        event.password,
      );
      
      if (user != null) {
        // Verificar si hay una nueva versión disponible después de autenticar
        final updateInfo = await _appVersionService.checkForUpdates();
        
        if (updateInfo != null) {
          // Si hay una actualización disponible, emitir estado con información de la actualización
          emit(AuthenticatedWithUpdate(user, 
            currentVersion: updateInfo['currentVersion'],
            latestVersion: updateInfo['latestVersion'],
            filePath: updateInfo['filePath'],
            releaseNotes: updateInfo['releaseNotes'],
            forceUpdate: updateInfo['forceUpdate'],
          ));
        } else {
          // Si no hay actualización, emitir estado normal de autenticado
          emit(Authenticated(user));
        }
      } else {
        emit(const AuthError('Error al iniciar sesión'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Maneja el evento de solicitud de cierre de sesión
  /// @param [event] Evento de cierre de sesión
  /// @param [emit] Emisor para cambiar el estado de autenticación
  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Verifica el estado actual de autenticación del usuario
  /// Comprueba si el usuario está autenticado y si el token es válido
  /// @param [event] Evento para verificar el estado de autenticación
  /// @param [emit] Emisor para cambiar el estado de autenticación
  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        if (user != null && await _authService.isTokenValid()) {
          // Verificar si hay una nueva versión disponible después de validar el token
          final updateInfo = await _appVersionService.checkForUpdates();
          
          if (updateInfo != null) {
            // Si hay una actualización disponible, emitir estado con información de la actualización
            emit(AuthenticatedWithUpdate(user, 
              currentVersion: updateInfo['currentVersion'],
              latestVersion: updateInfo['latestVersion'],
              filePath: updateInfo['filePath'],
              releaseNotes: updateInfo['releaseNotes'],
              forceUpdate: updateInfo['forceUpdate'],
            ));
          } else {
            // Si no hay actualización, emitir estado normal de autenticado
            emit(Authenticated(user));
          }
          return;
        }
      }
      
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  /// Maneja el evento de expiración del token de autenticación
  /// Cierra la sesión y muestra un mensaje de error antes de cambiar al estado no autenticado
  /// @param [event] Evento de token expirado
  /// @param [emit] Emisor para cambiar el estado de autenticación
  Future<void> _onTokenExpired(TokenExpired event, Emitter<AuthState> emit) async {
    if (state is! AuthError && state is! Unauthenticated) {
      await _authService.logout(); 
      
      emit(const AuthError('Sesión expirada. Por favor inicie sesión nuevamente.'));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(Unauthenticated());
    }
  }
  
  /// Libera los recursos utilizados por el bloc
  /// Cancela las suscripciones y temporizadores activos
  @override
  Future<void> close() {
    _authExpirationSubscription?.cancel();
    _tokenValidityTimer?.cancel();
    return super.close();
  }
}
