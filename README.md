# m50

# PARA CAMBIAR EL NOMBRE DE LA APP
```
Instalar el paquete
flutter pub add change_app_package_name

Y ejecutar:
dart run change_app_package_name:main com.new.package.name
```

# PARA GENERAR EL ICONO DE LA APP
```
Instalar el paquete
flutter_launcher_icons

Y ejecutar:

```

# PARA SUBIR A APPSTORE
```

```

# PARA ACTUALIZAR APPSTORE
```
Cambiar la versión en el pubspec.yaml
Ejecutar nuevamente Product -> Archive en XCode
Para actualizar en el dispositivo, abrir TestFlight y ejecutar la actualización
```

# PARA ACTUALIZAR EN GOOGLE PLAY
```
Cambia la versión en el pubspec.yaml
Genera el nuevo bundle con: flutter build appbundle --release
Abre Google Play Console
En el menú izquierdo Pruebas -> Prueba Interna
Crear nueva versión
Carga el bundle y Guardar
En la sección Testers, copia y envía el enlace.

# PARA ACTUALIZAR EN APPLE STORE        
```
Asegúrate de la versión en pubspec.yaml
Generamos un nuevo ipa -> flutter build ipa --release
Lo cargamos desde /build/ios/ipa/m50.ipa a la aplicación transporter de macOS.
Recibimos una confirmación en la misma aplicación