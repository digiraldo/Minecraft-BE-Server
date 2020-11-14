# Copias de Seguridad de los Mundos de Minecraft BE en una nube

##En este ejemplo realizaremos la copia de seguridad automática en la nube de Google Drive o cuenta de Google

Para aquellos que tienen un servidor dedicado de Minecraft y no quieren utilizar los servicios de [FTP](https://es.wikipedia.org/wiki/Protocolo_de_transferencia_de_archivos) o [SFTP](https://es.wikipedia.org/wiki/SSH_File_Transfer_Protocol) para guardar las copias de seguridad de sus mundos, este tutorial es el ideal ya que realizara la copia de seguridad automáticamente en la nube de Google Drive, Microsoft OneDrive, Amazon Drive, Dropbox, Mega y muchas más.

1. Instalar RClone y vincularlo a una cuenta de Google Drive

Inicie sesión en su servidor Linux usando SSH con un ratón y teclado copie y pegue el siguiente comando en la terminal:

```curl https://rclone.org/install.sh | sudo bash```

**Vamos a configurar RClone para que trabaje con nuestra nube de Google Drive**

Rclone dispone de un listado amplio de nubes públicas.  

Para utilizar una cuenta en rclone, teclearemos en nuestra terminal:

```rclone config```

**Ahora, entre las opciones, introduciremos n, para crear una nueva cuenta en Rclone:**


`No remotes found - make a new one`
`n) New remote`
`s) Set configuration password`
`q) Quit config`
`n/s/q>` 

**Nos pedirá que le pongamos un nombre (yo le he puesto drive)**

`name> drive`

**Nos saldrá el gran listado de nubes públicas:**

`Type of storage to configure.`  
`Enter a string value. Press Enter for the default ("").`  
`Choose a number from below, or type in your own value`  

`13 / Google Drive`  
` ``\ "drive"`  

`Storage>`

* Introducimos el número de la nube. En esta versión de RClone hay que introducir el número 13, correspondiente a Google Drive `Storage>13` y seguimos con el proceso.

Pregunta: `client_id> y client_secret>` , las dejamos por defecto en blanco pulsando Intro

Después pide el tipo de acceso: `scope>` , le doy acceso completo con el número 1 que es el acceso de lectura y escritura.  
`1 / Full access all files, excluding Application Data Folder.`  
` ``\ "drive"`

A los siguientes: `root_folder_id>` y `service_account_file>` las dejamos por defecto en blanco pulsando Intro

En `Edit advanced config? (y/n)`, escribimos n

En `Use auto config? (y/n)`, escribimos n

Ahora saltara el link y como estamos instalando RClone remotamente desde un terminal SSH, copiamos y pegamos en nuestro navegador web la url larga que nos aparece en el terminal, en este caso es la siguiente url resaltada en negrillas.

`Please go to the following link:` **`https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=202264815644.apps.googleusercontent.com&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive&state=b1MNpS32JLYwxrH1CtonQhz34F356`** `Log in and authorize rclone for access`
`Enter verification code>`


Se nos abrirá la información donde nos indica **Elegir una cuenta para ir a rclone**, Elegimos o introducimos usuario y contraseña de la cuenta de Google Drive y después nos pedirá los permisos:


`rclone desea acceder a tu Cuenta de Google`

`nombrecuenta@gmail.com`  
`Esta acción permitirá que rclone haga lo siguiente:`

`Ver, editar y borrar todos tus archivos de Google Drive le damos a conceder permisos de acceso a Rclone a nuestro Drive`

Hacemos click en *permitir* y nos saldrá el token o código de autorización

`Acceder`

`Copia este código, cambia a tu aplicación y pégalo allí:`  
`4/1Y0e-g4Ukgtt8smIVgVgkwg4CtXHdcDPIfdRnWrQMOFpK2BV2hSuJbyZNIA00Frjxs`

Copiamos el token que nos proporciona Google y volvemos a la terminal donde lo copiaremos:

`Enter verification code> 4/1Y0e-g4Ukgtt8smIVgVgkwg4CtXHdcDPIfdRnWrQMOFpK2BV2hSuJbyZNIA00Frjxs`

En `Configure this as a team drive?` , escribimos n

Si contamos con un disco de team drive o *Unidades compartidas* en nuestra cuenta de Google Drive y queremos usarlo, escribiremos **s**, de lo contrario escribimos **n** donde utilizaré *Mi unidad* de Google Drive.

`--------------------`  
`[drive]`  
`type = drive`  
`scope = drive`  
`(y) Yes this is OK (default)`

Escribimos y luego enter y nos saldrá nuestra unidad que hemos montado configurada y sus parámetros:

`Current remotes:`

`Name`       `Type`
`====`       `====`
`drive`      `drive`

Salimos escribiendo `q`

Ya tenemos configurada la Unidad con acceso a los archivos de la nube, el siguiente paso nos ayudara a montarla.


2. Montar la nube de Google Drive

* Vamos a montar la nube pública en nuestro servidor, como si fuera una unidad de disco duro. Para ello, necesitamos instalar Fuse si no lo tenemos instalado.

```sudo apt-get install fuse```

Luego crearemos la carpeta drive con el mismo nombre que la nube en RClone para evitar confusiones. Nos ubicamos en el `/home$` de nuestro Servidor y crearemos la carpeta con:


```sudo mkdir /home/drive```

Y configuramo fuse escribiendo en el terminal:

```sudo nano /etc/fuse.conf```

* Vamos a la línea final y quitamos los #

`# Allow non-root users to specify the allow_other or allow_root mount options.`  
`#user_allow_other`  

quedando de la siguiente manera con un espacio al comienzo de Allow

` ``Allow non-root users to specify the allow_other or allow_root mount options.`  
`user_allow_other`   


* Ahora vamos a configurar crontab para auto montar la nube al iniciar el sistema operativo escribiendo en el terminal:

```crontab -e```

introducimos `1` para editarn con nano

Al final de escribimos los siguiente:

```@reboot rclone mount drive: /home/drive --allow-other &```

Reiniciamos nuestro servidor:

```sudo reboot```

Ya lo tenemos todo listo, solo vamos a nuestra carpeta drive y veremos los archivos que tengamos en `Mi Unidad` de Google Drive en ```/home/pi/drive```


3. Configuracion del servidor
