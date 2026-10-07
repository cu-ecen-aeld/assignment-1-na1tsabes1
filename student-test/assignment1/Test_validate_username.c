#include "unity.h"
#include <stdbool.h>
#include <stdlib.h>
#include "../../examples/autotest-validate/autotest-validate.h"
#include "../../assignment-autotest/test/assignment1/username-from-conf-file.h"

/**
 * Este test verifica que el usuario "hardcodeado" en my_username()
 * (examples/autotest-validate/autotest-validate.c) coincide con el
 * valor leido desde conf/username.txt.
 */
void test_validate_my_username()
{
    // 1) Usuario hardcodeado en el codigo C.
    const char *hardcoded_username = my_username();

    // 2) Usuario leido desde conf/username.txt (el submodule lo provee).
    //    Devuelve memoria reservada con malloc -> hay que liberarla.
    char *conf_username = malloc_username_from_conf_file();

    // 3) Comprobar que ambas cadenas son exactamente iguales.
    TEST_ASSERT_EQUAL_STRING_MESSAGE(
        hardcoded_username,
        conf_username,
        "El usuario en autotest-validate.c no coincide con conf/username.txt"
    );

    free(conf_username);
}
