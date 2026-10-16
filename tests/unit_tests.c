#include <stdio.h>
#include <string.h>

#include "args/args.h"

static int check_int(const char* field, int actual, int expected)
{
    if (actual == expected)
    {
        return 0;
    }

    fprintf(stderr, "%s: expected %d, got %d\n", field, expected, actual);
    return 1;
}

static int check_string(const char* field, const char* actual, const char* expected)
{
    if (strcmp(actual, expected) == 0)
    {
        return 0;
    }

    fprintf(stderr, "%s: expected \"%s\", got \"%s\"\n", field, expected, actual);
    return 1;
}

static int test_lighting_defaults(void)
{
    lighting_t lighting = {
        .red = 1,
        .green = 2,
        .blue = 3,
        .mode = WAVE,
        .speed = 0,
        .brightness = 0,
        .random_colors = true,
    };

    lighting_init(&lighting);

    return check_int("red", lighting.red, 0)
        + check_int("green", lighting.green, 0)
        + check_int("blue", lighting.blue, 0)
        + check_int("mode", lighting.mode, STATIC)
        + check_int("speed", lighting.speed, 4)
        + check_int("brightness", lighting.brightness, 4)
        + check_int("random_colors", lighting.random_colors, false);
}

static int test_lighting_mode_names(void)
{
    static const struct
    {
        LMODE mode;
        const char* name;
    } expected[] = {
        { WAVE, "Wave" },
        { SPECTRUM, "Spectrum" },
        { BREATHING, "Breathing" },
        { ROLLING, "Rolling" },
        { CURVE, "Curve" },
        { SCAN, "Scan" },
        { CUSTOM, "Custom" },
        { RADIATION, "Radiation" },
        { RIPPLES, "Ripples" },
        { SINGLE_KEY, "Single key" },
        { STATIC, "Static" },
    };
    int failures = 0;

    for (size_t i = 0; i < sizeof(expected) / sizeof(expected[0]); i++)
    {
        failures += check_string(expected[i].name,
            lighting_mode_str(expected[i].mode), expected[i].name);
    }

    return failures;
}

static int test_args_defaults(void)
{
    args_t args = {
        .red = 1,
        .green = 2,
        .blue = 3,
        .lighting = WAVE,
        .speed = 0,
        .brightness = 0,
        .random_colors = true,
        .vendor_id = 1,
        .product_id = 2,
        .verbose = true,
    };

    args_init(&args);

    return check_int("red", args.red, 0)
        + check_int("green", args.green, 0)
        + check_int("blue", args.blue, 0)
        + check_int("lighting", args.lighting, STATIC)
        + check_int("speed", args.speed, 4)
        + check_int("brightness", args.brightness, 4)
        + check_int("random_colors", args.random_colors, false)
        + check_int("vendor_id", args.vendor_id, -1)
        + check_int("product_id", args.product_id, -1)
        + check_int("verbose", args.verbose, false);
}

static int test_args_parse_and_clamp(void)
{
    args_t args;
    char program[] = "unit-tests";
    char lighting[] = "WAVE";
    char red[] = "--red=300";
    char green[] = "--green=-9";
    char blue[] = "--blue=127";
    char speed[] = "--speed=0";
    char brightness[] = "--brightness=0";
    char random[] = "--random-colors";
    char vendor[] = "--vendor-id=0x046a";
    char product[] = "--product-id=0x0079";
    char lighting_option[] = "--lighting";
    char* argv[] = {
        program,
        lighting_option, lighting,
        red, green, blue,
        speed, brightness,
        random, vendor, product,
    };

    args_init(&args);
    args_parse((int)(sizeof(argv) / sizeof(argv[0])), argv, &args);

    return check_int("lighting", args.lighting, WAVE)
        + check_int("red", args.red, 255)
        + check_int("green", args.green, 0)
        + check_int("blue", args.blue, 127)
        + check_int("speed", args.speed, 0)
        + check_int("brightness", args.brightness, 1)
        + check_int("random_colors", args.random_colors, true)
        + check_int("vendor_id", args.vendor_id, 0x046a)
        + check_int("product_id", args.product_id, 0x0079);
}

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        fprintf(stderr, "Expected one test name\n");
        return 2;
    }

    if (strcmp(argv[1], "lighting-defaults") == 0)
    {
        return test_lighting_defaults() != 0;
    }
    if (strcmp(argv[1], "lighting-mode-names") == 0)
    {
        return test_lighting_mode_names() != 0;
    }
    if (strcmp(argv[1], "args-defaults") == 0)
    {
        return test_args_defaults() != 0;
    }
    if (strcmp(argv[1], "args-parse-and-clamp") == 0)
    {
        return test_args_parse_and_clamp() != 0;
    }

    fprintf(stderr, "Unknown test: %s\n", argv[1]);
    return 2;
}
