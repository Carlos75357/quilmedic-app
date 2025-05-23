# 📦 Quilmedic

## 🚀 Requisitos

- Flutter SDK
- Dispositivo Android con escáner integrado o emulador configurado
- API en ejecución
- ADB instalado y conectado

## Sobre el proyecto

El sdk que usa es el 28, la versión de flutter es la 3.29.1


## 🛠️ Configuración para Desarrollo

### 1. Instalar flutter sdk
https://ecm-pmdm-flutter.gitbook.io/1.-introduccion-a-flutter

Video tutorial: https://www.youtube.com/watch?v=Jji08gTHcZU&ab_channel=CodeSwallowEsp

Cuando se cambie la versión hay que cambiar el número en el archivo `pubspec.yaml`

Cuando el proyecto este descargador hay que ejecutar el siguiente comando `flutter pub get`

### 2. Definir variables sensibles (como tokens)

Para evitar exponer información sensible en el código fuente, se utiliza `--dart-define` para definir variables como el token maestro.

#### Ejemplo de configuración para `launch.json` en VSCode:

```json
{
  "name": "quilmedic (debug mode)",
  "request": "launch",
  "type": "dart",
  "flutterMode": "debug",
  "toolArgs": [
    "--dart-define",
    "MASTER_TOKEN=AQUÍ_TU_TOKEN"
  ]
}
```

## 2. Ejecutar en modo debug

Para probar la app conectada a la API local desde un móvil real:

```bash
adb reverse tcp:8000 tcp:8000
```

Esto redirige las peticiones de localhost:8000 en el dispositivo al mismo puerto en tu PC.

El comando se ejecuta cuando el dispositivo ya está conectado.

### 3. Compilar para producción
Usa el siguiente comando para generar el APK de producción:

```bash
flutter build apk --release --dart-define="MASTER_TOKEN=AQUÍ_TU_TOKEN"
```

El APK se generará en:

```swift
build/app/outputs/flutter-apk/app-release.apk
```