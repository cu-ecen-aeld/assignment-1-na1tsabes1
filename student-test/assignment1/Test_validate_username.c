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