# Assignment 1 - Guía de Implementación (Pasos 5 al 12)

### Paso 5: conf/username.txt

**Archivo:** `conf/username.txt`
```
na1tsabes1
```

- Una sola línea
- Sin espacios al inicio o final
- Sin líneas adicionales
- Debe coincidir con el username de GitHub

### Paso 6: Implementar Test_validate_username.c

**Archivo:** `student-test/assignment1/Test_validate_username.c`

```c
#include "unity.h"
#include <stdbool.h>
#include <string.h>
#include "../../examples/autotest-validate/autotest-validate.h"
#include "../../assignment-autotest/test/assignment1/username-from-conf-file.h"

void test_validate_my_username(void)
{
    const char *expected = my_username();
    const char *actual = malloc_username_from_conf_file();
    TEST_ASSERT_EQUAL_STRING_MESSAGE(expected, actual, "Usernames do not match");
    free((void *)actual);
}
```

### Paso 7: Actualizar autotest-validate.c

**Archivo:** `examples/autotest-validate/autotest-validate.c`

```c
const char *my_username(void)
{
    return "na1tsabes1";
}
```

### Paso 8: Re-ejecutar unit-test.sh

```bash
./unit-test.sh
```

### Paso 9: Script finder.sh

**Archivo:** `finder-app/finder.sh`

```bash
#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Error: Two arguments required: <filesdir> <searchstr>"
    exit 1
fi
filesdir="$1"
searchstr="$2"
if [ ! -d "$filesdir" ]; then
    echo "Error: '$filesdir' is not a valid directory"
    exit 1
fi
X=$(find "$filesdir" -type f | wc -l)
Y=$(grep -r "$searchstr" "$filesdir" 2>/dev/null | wc -l)
echo "The number of files are $X and the number of matching lines are $Y"
```

### Paso 10: Script writer.sh

**Archivo:** `finder-app/writer.sh`

```bash
#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Error: Two arguments required: <writefile> <writestr>"
    exit 1
fi
writefile="$1"
writestr="$2"
mkdir -p "$(dirname "$writefile")"
if ! echo "$writestr" > "$writefile"; then
    echo "Error: Could not create file '$writefile'"
    exit 1
fi
```

### Paso 11: Ejecutar finder-test.sh

```bash
./finder-app/finder-test.sh
# Output: success
```

### Paso 12: full-test.sh

```bash
./full-test.sh
```
