# 🔧 Solución al Error CONFIGURATION_NOT_FOUND

## ❌ Error que estás viendo:
```
Error: Exception: Error al registrar: [firebase_auth/unknown]
An internal error has occurred.
[CONFIGURATION_NOT_FOUND]
```

## ✅ Solución Paso a Paso

### 1. Habilitar Authentication en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto: **proyectofinal-fcbaa**
3. En el menú lateral, haz clic en **Authentication**
4. Si es la primera vez, haz clic en **Get Started**
5. Ve a la pestaña **Sign-in method**
6. Haz clic en **Email/Password**
7. **Habilita** el primer toggle (Email/Password)
8. Haz clic en **Save**

### 2. Verificar que Firestore esté habilitado

1. En Firebase Console, ve a **Firestore Database**
2. Si no existe, haz clic en **Create database**
3. Selecciona modo **Start in test mode** (para pruebas)
4. Elige una ubicación (recomendado: **southamerica-east1** para Perú)
5. Haz clic en **Enable**

### 3. Verificar que Storage esté habilitado

1. En Firebase Console, ve a **Storage**
2. Si no existe, haz clic en **Get started**
3. Acepta las reglas de seguridad por defecto
4. Elige la misma ubicación que Firestore
5. Haz clic en **Done**

### 4. Limpiar y Reconstruir el Proyecto

Después de habilitar los servicios en Firebase:

```bash
# Limpiar el proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Reconstruir
flutter run
```

### 5. Verificar el archivo google-services.json

Asegúrate de que el archivo `android/app/google-services.json` existe y contiene la configuración correcta de tu proyecto Firebase.

## 🔍 Verificación

Después de seguir estos pasos, intenta registrar un usuario nuevamente. El error debería desaparecer.

## 📝 Notas Importantes

- **Authentication debe estar habilitado** antes de poder registrar usuarios
- Si el error persiste, verifica que el **package name** en `google-services.json` coincida con el de tu app: `com.example.flutter_application_1_luisantony`
- Asegúrate de tener conexión a Internet
- Si usas un emulador, verifica que tenga acceso a Internet

## 🆘 Si el Error Persiste

1. Verifica que estés usando el proyecto Firebase correcto
2. Descarga nuevamente el archivo `google-services.json` desde Firebase Console:
   - Ve a **Project Settings** > **Your apps** > **Android app**
   - Descarga el archivo `google-services.json`
   - Reemplázalo en `android/app/google-services.json`
3. Reinicia el emulador/dispositivo
4. Ejecuta `flutter clean` y vuelve a compilar

