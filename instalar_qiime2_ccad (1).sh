#!/bin/bash
# =============================================================================
# Instalación de QIIME 2 2026.1 (distribución amplicon) en JupyterHub CCAD
# Grupo de Investigación en Ecología Microbiana de Ambientes Extremos - IMBIV
# =============================================================================
#
# Este script está pensado para correrse PASO A PASO (no de una sola vez)
# desde una Terminal de JupyterLab en https://lab.ccad.unc.edu.ar
#
# Cada estudiante debe ejecutar los bloques uno por uno, revisando que cada
# paso termine bien antes de seguir al siguiente.
#
# IMPORTANTE - PERSISTENCIA:
# /opt/conda/envs/ es almacenamiento EFÍMERO: vive en el contenedor de la
# sesión, que se recicla cada vez que apagás y volvés a entrar a JupyterHub.
# Si instalás el ambiente ahí (con --name), lo vas a perder al cerrar sesión.
#
# Por eso este script instala el ambiente con --prefix dentro de
# /home/jovyan/, que SÍ es almacenamiento persistente y sobrevive entre
# sesiones.
#
# Versión QIIME2: 2026.1 (distribución "amplicon", para datos de amplicones
# como 16S rRNA). Ver https://library.qiime2.org/quickstart/amplicon
#
# =============================================================================


# -----------------------------------------------------------------------------
# PASO 0: Verificar que conda esté disponible
# -----------------------------------------------------------------------------
conda --version


# -----------------------------------------------------------------------------
# PASO 1: Instalar mamba en el ambiente base
# -----------------------------------------------------------------------------
# mamba resuelve dependencias mucho más rápido que conda. Se instala una sola
# vez en el ambiente "base" y después se usa para crear el resto de ambientes.
conda install -n base -c conda-forge mamba -y


# -----------------------------------------------------------------------------
# PASO 2: Crear el ambiente de QIIME2 2026.1 DENTRO del home persistente
# -----------------------------------------------------------------------------
# Usamos --prefix (no --name) para que el ambiente quede guardado en
# /home/jovyan/envs/, y así sobreviva a apagar/cerrar la sesión de JupyterHub.
#
# Este paso tarda varios minutos (instala decenas de paquetes científicos).
#
# NOTA: si un intento anterior falló a mitad de camino, este comando puede
# preguntar algo como:
#   "Found conda-prefix at '/home/jovyan/envs/qiime2-amplicon-2026.1'. Overwrite?: [y/N]"
# En ese caso responder "y" para sobreescribir el directorio a medio crear.
mamba env create \
  --prefix /home/jovyan/envs/qiime2-amplicon-2026.1 \
  --file https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2026.1/amplicon/released/qiime2-amplicon-ubuntu-latest-conda.yml


# -----------------------------------------------------------------------------
# PASO 3: Activar el ambiente y verificar la instalación
# -----------------------------------------------------------------------------
# Como instalamos con --prefix, activamos usando la ruta completa (no el
# nombre corto).
conda activate /home/jovyan/envs/qiime2-amplicon-2026.1
qiime --version
# Debería mostrar algo como:
#   q2cli version 2026.1.0
#   Run `qiime info` for more version details.


# -----------------------------------------------------------------------------
# PASO 4: Registrar el ambiente como kernel de Jupyter
# -----------------------------------------------------------------------------
# Esto permite elegir "QIIME2 Amplicon 2026.1" como kernel al abrir o crear
# un notebook nuevo en JupyterLab.
#
# IMPORTANTE: el ambiente debe estar ACTIVADO antes de correr el segundo
# comando (el prompt debe mostrar "(qiime2-amplicon-2026.1)" y no "(base)"),
# para que el kernel se registre con el Python correcto.
mamba install ipykernel -y
python -m ipykernel install --user --name qiime2-amplicon-2026.1 --display-name "QIIME2 Amplicon 2026.1"


# =============================================================================
# PASO 5: Usar QIIME2 dentro de un notebook
# =============================================================================
#
# 1. Abrir/crear un notebook y elegir el kernel "QIIME2 Amplicon 2026.1"
#    en el selector (arriba a la derecha).
#
# 2. IMPORTANTE: el kernel de Jupyter NO activa automáticamente el ambiente
#    conda completo. Hay que agregar esta celda al PRINCIPIO de cada
#    notebook, antes de correr cualquier comando de QIIME2:
#
#      import os
#      os.environ['PATH'] = '/home/jovyan/envs/qiime2-amplicon-2026.1/bin:' + os.environ['PATH']
#
# 3. Después de correr esa celda una vez, ya se puede usar QIIME2 en
#    cualquier celda con el prefijo "!", por ejemplo:
#
#      !qiime --version
#      !qiime demux summarize --i-data demux.qza --o-visualization demux.qzv
#
#    Esto permite combinar comandos QIIME2 con análisis en Python/pandas
#    dentro del mismo notebook.
#
# =============================================================================


# -----------------------------------------------------------------------------
# PASO 6 (opcional): Limpiar caché de paquetes para liberar espacio en disco
# -----------------------------------------------------------------------------
# conda clean --all -y
