# Paso 1: Entramos a CCAD
Vamos a ingresar al entorno JupyterHub a través de Supercómputos de la UNC
https://lab.ccad.unc.edu.ar, este link nos permite ingresar con usuarios mi.unc o unc

## 1.1 Configurar computadora
Una vez que ingreses a través de tu cuenta de @mi.unc / @unc se abrirá una página donde vas
a poder configurar el servidor. 
La configuración preestablecida es:
- Imagen: Simple
- Interfaz: Laboratorio
- Recursos: Elegí la opción de 48 G de RAM y 12 cores.

# Paso 2: Instalar QIIME2 en el entorno JupyterHub
Ir al archivo instalar_qiime2_ccad.sh y seguir los pasos desde una TERMINAL.

# Paso 3: Subir las secuencias

Las secuencias que vamos a utilizar estan en un archivo llamado 
"secuencias_práctico" en el drive del curso. Las vamos a descargar, y una 
vez descargadas las vamos a subir al entorno Jupyter. 

## 3.1: Crear una carpeta de trabajo

El espacio de trabajo puede tener el nombre que quieras, armá una carpeta
donde puedas subir todos los archivos de trabajo (por ej. "archivos",
o "curso"). 
IMPORTANTE: No subas los archivos de trabajo, ni modifiques los archivos
preexistentes dentro de la carpeta "envs". Esa carpeta contiene el 
ambiente de QIIME2. 

## 3.2: Crear una subcarpeta para las secuencias

Armá una carpeta llamada `raw_sequences` dentro de la carpeta de trabajo.
La tracucción en inglés significa "secuencias crudas". 
Luego descargá el archivo `secuencias_practico.zip` situado en el drive
del curso. Una vez descargado, descomprimilo y deslizá la carpeta a tu sesión de
JupyterHub, dentro de la carpeta `raw_sequences`
(podes arrastrarlo al panel izquierdo del explorador de archivos
o utilizá el botón "Upload Files" y seleccioná el archivo desde tu directorio).

# Paso 4: Manifiesto

El archivo manifiesto describe dónde están ubicados los archivos FASTQ de
cada muestra y cómo deben ser interpretados por QIIME 2 al momento de
importarlos. A diferencia de otros métodos de importación, el manifiesto
NO requiere renombrar los archivos FASTQ: alcanza con indicar, para cada
muestra, la ruta absoluta de su archivo forward (R1) y su archivo reverse
(R2).

## 4.1 Comprimir los archivos FASTQ (si no lo están ya)

QIIME 2 requiere que los archivos estén comprimidos en formato `.gz`. Si tus
archivos todavía terminan en `.fastq` (sin comprimir), comprimilos así
(reemplazá los nombres por los de tus propios archivos):

```bash
!gzip ruta/a/tu_archivo_R1.fastq
!gzip ruta/a/tu_archivo_R2.fastq
```

Esto genera automáticamente `tu_archivo_R1.fastq.gz` y
`tu_archivo_R2.fastq.gz`, y borra el archivo `.fastq` original.

AYUDA: El nombre de los archivos los tienen en un .txt llamado 
`nombres_secuencias` para que puedan copiar y pegar los nombres
de cada una de las secuencias.

## 4.2 Crear tu propio archivo manifest.csv

Ahora armá tu propio manifiesto a mano. En JupyterLab: File → New →
Text File. El archivo debe tener un encabezado fijo
(`sample-id,absolute-filepath,direction`) y una fila por cada combinación
de muestra + dirección (forward/reverse).

Pasos para completarlo correctamente:

1. Confirmá tu ruta absoluta de trabajo corriendo `!pwd` en una celda.
   Normalmente vas a estar en `/home/jovyan`.
2. Mirá los nombres reales de tus 6 archivos con
   `!ls raw_sequences/secuencias_practico`.
3. Para cada muestra, elegí un `sample-id` corto y sin espacios (podés
   guiarte por el nombre del archivo, o usar el nombre real de la muestra
   si lo sabés).
4. Completá la ruta ABSOLUTA de cada archivo (no relativa) — es decir,
   empezando por `/home/jovyan/...`, no por `archivos/...`.
5. Agregá `forward` a los archivos R1, y `reverse` a los archivos R2.

Estructura esperada (con valores de EJEMPLO, no copiar tal cual — armá el
tuyo con tus propios nombres de archivo y rutas):

```
sample-id,absolute-filepath,direction
<tu-sample-id-1>,/home/jovyan/<tu-ruta>/<tu-archivo-R1>.fastq.gz,forward
<tu-sample-id-1>,/home/jovyan/<tu-ruta>/<tu-archivo-R2>.fastq.gz,reverse
<tu-sample-id-2>,/home/jovyan/<tu-ruta>/<tu-archivo-R1>.fastq.gz,forward
<tu-sample-id-2>,/home/jovyan/<tu-ruta>/<tu-archivo-R2>.fastq.gz,reverse
```

Guardalo como `manifest.csv` dentro de tu carpeta `archivos/`.

Notas importantes:
- Cada muestra aparece dos veces: una fila `forward` (R1) y otra `reverse` (R2).
- El `sample-id` puede contener guiones medios (`-`), pero no debe contener
  guiones bajos (`_`).
- Antes de seguir, verificá que cada ruta que escribiste exista realmente.
  Podés probarlo con `!ls -la <la-ruta-que-escribiste>` para cada archivo.
- Un error muy común es escribir la ruta relativa (`archivos/...`) en vez
  de la absoluta (`/home/jovyan/archivos/...`) — QIIME 2 va a fallar si la
  ruta no es absoluta.


# Paso 5: Activar el ambiente QIIME 2 y verificar la instalación

En una Terminal de JupyterLab (o en una celda de notebook agregando `!`
al inicio):

```bash
conda activate /home/jovyan/envs/qiime2-amplicon-2026.1
qiime --help
```

Si usás un notebook (no Terminal), agregá primero esta celda al principio
para que QIIME 2 esté disponible en las celdas con `!`:

```python
import os
os.environ['PATH'] = '/home/jovyan/envs/qiime2-amplicon-2026.1/bin:' + os.environ['PATH']
```

Y verificá con:

```bash
!qiime --version
```


# Paso 6: Importación de datos

Utilizando el manifiesto creado en el Paso 4, importamos las secuencias a
QIIME 2.

```python
!qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.csv \
  --input-format PairedEndFastqManifestPhred33 \
  --output-path four-points.qza
```

Salida esperada:
```
Imported archivos/manifest.csv as PairedEndFastqManifestPhred33 to archivos/four-points.qza
```

## Resumen y visualización

```bash
!qiime demux summarize \
  --i-data four-points.qza \
  --o-visualization four-points.qzv
```

Salida esperada:
```
Saved Visualization to: archivos/four-points.qzv
```
Confirmemos que el archivo se generó:

```bash
!ls -la four-points.qza
```

Para visualizar el resultado, en JupyterLab no se usa `qiime tools view`
(ese comando abre una ventana gráfica local, que no funciona en un servidor
remoto). En su lugar, hacé doble clic sobre el archivo `four-points.qzv`
en el explorador de archivos de JupyterLab, o subilo a
https://view.qiime2.org desde tu computadora.
