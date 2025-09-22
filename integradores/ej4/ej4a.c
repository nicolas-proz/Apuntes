#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej4a.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
bool EJERCICIO_1A_HECHO = true;

// OPCIONAL: implementar en C
void init_fantastruco_dir(fantastruco_t* card) {
    card->__dir_entries = 2;

    // reservar memoria para el directorio
    card->__dir = malloc(card->__dir_entries * sizeof(directory_entry_t*));
    if (!card->__dir) return; // manejar error

    // crear entradas
    directory_entry_t* sleep_entry = create_dir_entry("sleep", (void*)sleep);
    directory_entry_t* wake_entry  = create_dir_entry("wakeup", (void*)wakeup);

    // guardarlas en el directorio
    card->__dir[0] = sleep_entry;
    card->__dir[1] = wake_entry;
}


/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - summon_fantastruco
 */
bool EJERCICIO_1B_HECHO = true;

// OPCIONAL: implementar en C
fantastruco_t* summon_fantastruco() {
    fantastruco_t *res = malloc(sizeof(fantastruco_t));
    init_fantastruco_dir(res);
    res->face_up = 1;
    res->__archetype = NULL;
    return res;
}
