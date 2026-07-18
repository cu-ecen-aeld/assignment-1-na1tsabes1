# Assignment 1 — Guía Completa para Principiantes

## Índice

1. [Conceptos básicos](#1-conceptos-básicos)
2. [Setup del repositorio](#2-setup-del-repositorio)
3. [Problemas de WSL y cómo los solucioné](#3-problemas-de-wsl-y-cómo-los-solucioné)
4. [Pasos 5-8: Unit tests de Unity](#4-pasos-5-8-unit-tests-de-unity)
5. [Pasos 9-10: Scripts finder.sh y writer.sh](#5-pasos-9-10-scripts-findersh-y-writersh)
6. [Pasos 11-12: Tests de integración](#6-pasos-11-12-tests-de-integración)
7. [Glosario](#7-glosario)

---

## 1. Conceptos básicos

### ¿Qué es WSL?
**WSL (Windows Subsystem for Linux)** permite ejecutar Linux dentro de Windows sin necesidad de una máquina virtual. Tienes 3 distribuciones instaladas:
- **Kali Linux** → orientada a seguridad
- **Ubuntu** → la más usada para desarrollo
- **Arch Linux** → rolling release, minimalista

Cuando abres Windows Terminal y seleccionas "Ubuntu", se conecta a WSL y te da una terminal de Linux.

### ¿Qué es CMake?
Es una herramienta que **genera archivos Makefile** a partir de un `CMakeLists.txt`. No compila directamente, sino que prepara el sistema de compilación para que `make` compile. Piensa en él como un "traductor" que adapta el código a tu sistema.

### ¿Qué es Make?
Lee un `Makefile` (generado por CMake) y ejecuta los comandos necesarios para compilar el código (llamar al compilador `gcc`, enlazar archivos, etc.).

### ¿Qué es Ruby?
Lenguaje de programación. En este proyecto se usa para **generar automáticamente** los "test runners" (archivos que conectan los tests con el framework de pruebas Unity).

### ¿Qué es Unity?
Es un **framework de testing para C**. Permite escribir funciones `test_...()` y Unity las ejecuta, reportando si pasan o fallan.

### ¿Qué es un submodule de Git?
Es un repositorio de Git dentro de otro repositorio. Aquí `assignment-autotest/` es un submodule que apunta a otro repo con los tests automatizados. No tiene el código directamente, sino una referencia a un commit específico de ese otro repo.

---

## 2. Setup del repositorio

### ¿Por qué estos comandos?

```bash
git remote add assignments-base https://github.com/cu-ecen-aeld/aesd-assignments.git
```

**Explicación:** Un `remote` es como un "acceso directo" a un repositorio remoto. Tu repo (`origin`) apunta a `assignment-1-na1tsabes1` (tu fork personal). `assignments-base` apunta al repositorio oficial de la clase. Así puedes traer actualizaciones del profesor.

```bash
git fetch assignments-base
```

**Explicación:** Descarga los cambios del repositorio oficial pero **sin fusionarlos** todavía. Es como bajar un archivo a tu escritorio sin abrirlo.

```bash
git merge assignments-base/master
```

**Explicación:** Fusiona lo que descargaste (`assignments-base/master`) con tu rama actual (`master`). Ahora tu código tiene todo lo del repositorio oficial.

```bash
git submodule update --init --recursive
```

**Explicación:** 
- `--init`: Si el submodule nunca se descargó, lo clona por primera vez
- `--recursive`: Si el submodule tiene sus propios submodules, también los descarga (como matrioskas)
- Sin este comando, la carpeta `assignment-autotest/` estaría vacía

---

## 3. Problemas de WSL y cómo los solucioné

### Problema 1: La terminal se corrompe visualmente

**Síntomas:** Aparecen números, letras, texto superpuesto, la pantalla se desconfigura.

**Causa raíz:** El plugin `zsh-autocomplete` de Oh My Zsh. Este plugin muestra un menú desplegable mientras escribes (como el autocompletado del móvil), pero en WSL no se limpia bien y deja basura visual. También conflictúa con `zsh-syntax-highlighting`.

**Otro problema:** WSL2 a veces reporta un tamaño de pantalla incorrecto (`131072x1`). Es como si la terminal creyera que mide 131072 píxeles de ancho y 1 de alto. Obviamente todo se ve mal.

**Soluciones aplicadas en las 3 distros (Kali, Ubuntu, Arch):**

1. **Eliminé `zsh-autocomplete`** del archivo `~/.zshrc` (en la lista `plugins=()`)
2. **Agregué una función `__fix_screen()`** que se ejecuta al abrir la terminal y fuerza el tamaño correcto usando `stty`
3. **Agregué un alias `termfix`** — si la pantalla se corrompe, escribes `termfix` y se resetea
4. **Limpié la caché de Powerlevel10k** (tema de la terminal) porque guardaba el prompt con un tamaño antiguo

**Archivos modificados en WSL:**
- `~/.zshrc` — configuración principal de Zsh
- `~/.bashrc` — por si usas Bash en lugar de Zsh

### Problema 2: cmake no está instalado

**Error al ejecutar `./unit-test.sh`:**
```
cmake: command not found
```

**Solución:** Instalar cmake con:
```bash
sudo apt install cmake
```

**Explicación:** `sudo` = superuser do (ejecutar como administrador). `apt` = gestor de paquetes de Ubuntu. `install cmake` = descarga e instala cmake y sus dependencias.

### Problema 3: cmake 4.x no acepta `VERSION 3.0.0`

**Error:**
```
Compatibility with CMake < 3.5 has been removed from CMake.
```

**Explicación:** Tu cmake es versión 4.2.3. Las versiones modernas de cmake eliminan el soporte para versiones muy antiguas (menores a 3.5). Los archivos `CMakeLists.txt` del proyecto decían `cmake_minimum_required(VERSION 3.0.0)`, que es demasiado antiguo para cmake 4.x.

**Solución:** Cambiar a `VERSION 3.5.0` en todos los `CMakeLists.txt`:

| Archivo | Cambio |
|---------|--------|
| `CMakeLists.txt` (raíz) | `3.0.0` → `3.5.0` |
| `assignment-autotest/CMakeLists.txt` | `3.0.0` → `3.5.0` |

Los archivos dentro de `assignment-autotest/Unity/` ya estaban en `3.5`, no hacía falta tocarlos.

### Problema 4: falta Ruby

**Error durante la compilación:**
```
ruby: command not found
```

**Explicación:** El script `auto_generate.sh` usa Ruby para ejecutar `generate_test_runner.rb`, que genera automáticamente los "test runners" (archivos que conectan tus tests con Unity).

**Solución:**
```bash
sudo apt install ruby
```

---

## 4. Pasos 5-8: Unit tests de Unity

### Estructura del proyecto

```
assignment-1-na1tsabes1/
├── conf/
│   ├── username.txt          <-- Tu usuario de GitHub (paso 5)
│   └── assignment.txt        <-- Número de assignment (assignment1)
├── examples/
│   └── autotest-validate/
│       ├── autotest-validate.c    <-- Código con función my_username() (paso 7)
│       └── autotest-validate.h    <-- Header que declara my_username()
├── student-test/
│   └── assignment1/
│       └── Test_validate_username.c  <-- Test que debes implementar (paso 6)
├── assignment-autotest/       <-- Submódulo (tests automatizados)
│   ├── test/assignment1/
│   │   ├── Test_hello.c       <-- Test básico de Unity
│   │   ├── Test_assignment_validate.c  <-- Test de validación
│   │   └── username-from-conf-file.h   <-- Header que lee conf/username.txt
│   └── Unity/                 <-- Framework de testing Unity
├── CMakeLists.txt             <-- Configuración de cmake
├── unit-test.sh               <-- Script que compila y ejecuta tests
└── full-test.sh               <-- Script que prueba todo
```

### Paso 5: conf/username.txt

**¿Qué es?** Es un archivo de texto plano que contiene tu nombre de usuario de GitHub.

**Antes:**
```
your-github-username-here-in-conf-file
```

**Después:**
```
na1tsabes1
```

**Reglas importantes:**
- Sin espacios al inicio o final
- Sin líneas extra después del username
- Solo una línea
- Debe coincidir con lo que pongas en el paso 7

**¿Por qué?** El test del paso 6 lee este archivo y compara su contenido con el username hardcodeado en `autotest-validate.c`. Si no coinciden, el test falla.

### Paso 6: student-test/assignment1/Test_validate_username.c

**¿Qué es?** Es un archivo de test usando el framework Unity. Contiene una función `test_validate_my_username()` que Unity ejecutará automáticamente.

**Antes (código placeholder que no sirve):**
```c
void test_validate_my_username()
{
    TEST_ASSERT_TRUE_MESSAGE(true, "AESD students, please fix me!");
}
```

Este código **siempre pasa** porque `TEST_ASSERT_TRUE_MESSAGE(true, ...)` verifica que `true` sea... `true`. No prueba nada útil.

**Después (implementación correcta):**
```c
void test_validate_my_username()
{
    const char *expected = my_username();
    const char *actual = malloc_username_from_conf_file();
    TEST_ASSERT_EQUAL_STRING_MESSAGE(expected, actual, "Los usernames no coinciden");
    free((void *)actual);
}
```

**Explicación línea por línea:**

| Línea | ¿Qué hace? |
|-------|------------|
| `const char *expected = my_username();` | Llama a la función `my_username()` que está en `examples/autotest-validate/autotest-validate.c`. Esta función devuelve el string hardcodeado (paso 7). |
| `const char *actual = malloc_username_from_conf_file();` | Llama a `malloc_username_from_conf_file()` declarada en `assignment-autotest/test/assignment1/username-from-conf-file.h`. Esta función **lee** el archivo `conf/username.txt`, reserva memoria con `malloc()`, y devuelve su contenido. |
| `TEST_ASSERT_EQUAL_STRING_MESSAGE(expected, actual, "Los usernames no coinciden");` | Compara los dos strings. Si son iguales → test pasa. Si son diferentes → test falla con el mensaje "Los usernames no coinciden". |
| `free((void *)actual);` | Libera la memoria que `malloc_username_from_conf_file()` reservó con `malloc()`. **Importante:** toda memoria reservada con `malloc()` debe liberarse con `free()` para evitar memory leaks. |

**¿Por qué se compara de esta forma?** Para verificar que:
1. El archivo `conf/username.txt` tiene el username correcto
2. La función `my_username()` devuelve el mismo username
3. Todo está sincronizado

### Paso 7: examples/autotest-validate/autotest-validate.c

**¿Qué es?** Es el código fuente que el test va a probar. Contiene la función `my_username()` que debe devolver tu username.

**Antes:**
```c
const char *my_username()
{
    return "todo-please-enter-your-username-here-in-my_username";
}
```

**Después:**
```c
const char *my_username()
{
    return "na1tsabes1";
}
```

**Regla de oro:** El string aquí debe ser **EXACTAMENTE IGUAL** al que pusiste en `conf/username.txt`. Si aquí pones `"na1tsabes1"` y en el archivo pusiste `"Na1tsabes1"` (con mayúscula), el test falla.

### Paso 8: ./unit-test.sh

**¿Qué hace este script?**
```bash
#!/bin/bash
mkdir -p build       # Crea la carpeta build (si no existe)
cd build             # Entra a build
cmake ..             # Genera los Makefiles a partir de CMakeLists.txt
make clean           # Limpia compilaciones anteriores
make                 # Compila usando los Makefiles
cd ..                # Vuelve al directorio raíz
./build/assignment-autotest/assignment-autotest  # Ejecuta los tests
```

**Problema que tiene:** `make clean` se ejecuta antes de `make`, pero la primera vez no hay Makefile todavía (cmake lo acaba de generar). Falla con un error pero continúa gracias a que no tiene `set -e`.

**Resultado esperado tras pasos 5-7:**
```
test_hello:PASS
test_assignment_validate:PASS
test_validate_my_username:PASS
-----------------------
3 Tests 0 Failures 0 Ignored
OK
```

---

## 5. Pasos 9-10: Scripts finder.sh y writer.sh

### Conceptos previos

#### Shebang (`#!/bin/bash`)
Es la primera línea de un script. Le dice al sistema qué intérprete usar para ejecutar el script. `#!/bin/bash` = usa Bash.

#### Variables especiales de Bash
| Variable | Significado |
|----------|-------------|
| `$#` | Número de argumentos pasados al script |
| `$1`, `$2`, ... | Primer, segundo, etc. argumento |
| `$0` | Nombre del script |
| `$?` | Código de retorno del último comando (0 = éxito) |

#### Exit codes
- `exit 0` = el script terminó correctamente
- `exit 1` = el script terminó con error (convención)

#### `$(comando)`
Ejecuta el comando y devuelve su salida. Ej: `$(find ...)` ejecuta `find` y el resultado se asigna a una variable.

#### `dirname`
Devuelve la ruta del directorio padre de una ruta.
```bash
dirname /tmp/aesd/assignment1/sample.txt   →   /tmp/aesd/assignment1
```

### Paso 9: finder-app/finder.sh

```bash
#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Error: Se requieren 2 argumentos: <directorio> <string>"
    exit 1
fi

filesdir="$1"
searchstr="$2"

if [ ! -d "$filesdir" ]; then
    echo "Error: '$filesdir' no es un directorio valido"
    exit 1
fi

X=$(find "$filesdir" -type f | wc -l)
Y=$(grep -r "$searchstr" "$filesdir" 2>/dev/null | wc -l)

echo "The number of files are $X and the number of matching lines are $Y"
```

**Explicación detallada:**

| Parte | Explicación |
|-------|-------------|
| `#!/bin/bash` | Indica que el intérprete es Bash |
| `if [ $# -ne 2 ]` | `$#` = número de argumentos. `-ne` = not equal. Si no son exactamente 2 argumentos... |
| `echo "Error: ..."` | Imprime mensaje de error |
| `exit 1` | Termina el script con código 1 (error) |
| `filesdir="$1"` | Guarda el primer argumento en la variable `filesdir` |
| `searchstr="$2"` | Guarda el segundo argumento en `searchstr` |
| `if [ ! -d "$filesdir" ]` | `! -d` = "not a directory". Si NO es un directorio... |
| `X=$(find "$filesdir" -type f \| wc -l)` | `find "$filesdir" -type f` = busca todos los archivos regulares (-type f) en el directorio y subdirectorios. `wc -l` = cuenta las líneas (número de archivos). `$(...)` = captura el resultado. |
| `Y=$(grep -r "$searchstr" "$filesdir" 2>/dev/null \| wc -l)` | `grep -r` = busca recursivamente el string. `2>/dev/null` = descarta errores (permisos, etc.). `wc -l` = cuenta las líneas que coinciden. |
| `echo "The number of files are $X..."` | Imprime el resultado en el formato requerido |

### Paso 10: finder-app/writer.sh

```bash
#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Error: Se requieren 2 argumentos: <ruta-archivo> <string>"
    exit 1
fi

writefile="$1"
writestr="$2"

mkdir -p "$(dirname "$writefile")"

if ! echo "$writestr" > "$writefile"; then
    echo "Error: No se pudo crear el archivo '$writefile'"
    exit 1
fi
```

**Explicación detallada:**

| Parte | Explicación |
|-------|-------------|
| `mkdir -p "$(dirname "$writefile")"` | `dirname` extrae la ruta del directorio (ej: `/tmp/aesd/assignment1`). `mkdir -p` crea ese directorio y todos los padres necesarios (`-p` = parents). Si el directorio ya existe, no da error. |
| `echo "$writestr" > "$writefile"` | `echo` imprime el texto. `>` redirige la salida al archivo, **sobrescribiendo** si existe. |
| `if ! echo ...` | `!` = negación. Si `echo` falla (no pudo escribir), ejecuta el bloque de error. |
| `exit 1` | Si no se pudo crear el archivo, termina con error. |

**¿Por qué `mkdir -p` antes de escribir?** Porque si escribes `writer.sh /tmp/aesd/assignment1/sample.txt ios`, el directorio `/tmp/aesd/assignment1/` puede no existir. `mkdir -p` lo crea automáticamente.

---

## 6. Pasos 11-12: Tests de integración

### Paso 11: finder-test.sh

**¿Qué hace `finder-test.sh`?**

1. Lee `conf/username.txt` para obtener tu username
2. Lee `conf/assignment.txt` para verificar que es `assignment1`
3. Crea 10 archivos en `/tmp/aeld-data/` con el formato `username1.txt`, `username2.txt`, etc., cada uno conteniendo `AELD_IS_FUN`
4. Ejecuta `finder.sh` buscando `AELD_IS_FUN` en `/tmp/aeld-data/`
5. Compara la salida con `"The number of files are 10 and the number of matching lines are 10"`
6. Si coincide → imprime "success". Si no → "failed"

**¿Por qué se espera que archivos y líneas coincidan?** Cada archivo contiene exactamente el string buscado. 10 archivos, cada uno con 1 línea que contiene el string → 10 archivos, 10 líneas coincidentes.

**Importante:** `finder-test.sh` debe ejecutarse **dentro de `finder-app/`**, no desde la raíz:
```bash
cd finder-app
./finder-test.sh
```
Esto es porque el script usa rutas relativas como `../conf/assignment.txt`. Si lo ejecutas desde la raíz, `../conf/` sería el padre de la raíz, que no existe.

### Paso 12: full-test.sh

**¿Qué hace `full-test.sh`?**

Es el test **completo** que ejecuta GitHub Actions automáticamente cuando haces push. Hace todo en orden:

1. **Compila y ejecuta los unit tests** (Unity) → llama a `unit-test.sh`
2. **Ejecuta `finder-test.sh`** dentro de `finder-app/` sin argumentos (usa defaults: 10 archivos, `AELD_IS_FUN`)
3. **Ejecuta `finder-test.sh`** con un directorio aleatorio (para verificar que funciona con diferentes rutas)
4. Reporta si todo pasó o no

---

## 7. Glosario

| Término | Definición |
|---------|------------|
| **WSL** | Windows Subsystem for Linux — Linux dentro de Windows |
| **Distro** | Distribución de Linux (Ubuntu, Kali, Arch) |
| **Terminal** | Programa que te da acceso a la línea de comandos |
| **Shell** | Intérprete de comandos (Bash, Zsh) |
| **Bash** | El shell más común en Linux |
| **Zsh** | Shell más moderno, con plugins y temas (usas este) |
| **Oh My Zsh** | Framework para gestionar la configuración de Zsh |
| **Powerlevel10k** | Tema para Zsh que hace el prompt bonito |
| **Prompt** | El texto que ves antes de escribir comandos (ej: `naitsabes@ubuntu:~$`) |
| **Plugin** | Extensión que agrega funcionalidad (autocompletado, syntax highlighting) |
| **CMake** | Herramienta que genera archivos de compilación |
| **Make** | Herramienta que compila el código usando las instrucciones de CMake |
| **Makefile** | Archivo con instrucciones para compilar (generado por CMake) |
| **Compiler** | Programa que convierte código C en archivos ejecutables (gcc) |
| **Unity** | Framework para hacer tests en C |
| **Test runner** | Código generado automáticamente que conecta tus tests con Unity |
| **Ruby** | Lenguaje usado para generar los test runners |
| **Submodule** | Repositorio de Git dentro de otro repositorio |
| **git remote** | Acceso directo a un repositorio remoto |
| **git fetch** | Descargar cambios sin fusionarlos |
| **git merge** | Fusionar cambios descargados con tu código |
| **symlink** | Acceso directo (como un .lnk de Windows) |
| **stty** | Comando para configurar la terminal (tamaño, etc.) |
| **tput** | Comando que consulta la capacidad de la terminal |
| **malloc** | Función de C que reserva memoria dinámica |
| **free** | Función de C que libera memoria reservada con malloc |
| **memory leak** | Olvidar liberar memoria → el programa consume más RAM de la cuenta |
| **exit code** | Número que un script devuelve al terminar (0 = bien, 1 = error) |
| **Shebang** | Primera línea de un script (`#!/bin/bash`) que indica el intérprete |
| **Redirección** | `>` envía salida a un archivo. `2>/dev/null` descarta errores |
| **Pipeline** | `\|` conecta la salida de un comando con la entrada de otro |
| **apt** | Gestor de paquetes de Ubuntu/Debian |
| **sudo** | Ejecutar un comando como administrador (superuser do) |

---

## Resumen visual de todo el flujo

```
Tu código (C)  →  CMake genera Makefile  →  Make compila  →  Ejecutable
                                                                     ↓
conf/username.txt ──────────────────────────────────────────────┐    ↓
examples/autotest-validate.c ──► my_username() ──► "na1tsabes1" ├──► TEST (Unity) ──► PASS/FAIL
student-test/Test_validate_username.c ──────────────────────────┘
                                                                     
finder.sh ──► busca archivos y strings ──► "The number of files are X..."
writer.sh ──► escribe archivos ──► /tmp/aeld-data/username1.txt ...
full-test.sh ──► ejecuta TODO y verifica que pase
```

**Para rehacerlo desde cero manualmente:**

```bash
# 1. Setup del repo
git remote add assignments-base https://github.com/cu-ecen-aeld/aesd-assignments.git
git fetch assignments-base
git merge assignments-base/master
git submodule update --init --recursive

# 2. Instalar dependencias
sudo apt install cmake ruby

# 3. Fix de versión de cmake (editar 2 archivos)
# CMakeLists.txt: 3.0.0 → 3.5.0
# assignment-autotest/CMakeLists.txt: 3.0.0 → 3.5.0

# 4. Configurar username (3 archivos)
# conf/username.txt → na1tsabes1
# student-test/assignment1/Test_validate_username.c → implementar test
# examples/autotest-validate/autotest-validate.c → return "na1tsabes1"

# 5. Compilar y probar
./unit-test.sh

# 6. Crear scripts
# finder-app/finder.sh
# finder-app/writer.sh
chmod +x finder-app/finder.sh finder-app/writer.sh

# 7. Probar todo
cd finder-app && ./finder-test.sh && cd ..
./full-test.sh
```
