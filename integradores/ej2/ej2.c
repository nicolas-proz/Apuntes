#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej2.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_2A_HECHO = false;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_2B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_2C_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {
    uint32_t hash_comp = fun_hash(compartida);
    for (int i = 0; i < 255; i++) {
        for (int j = 0; j < 255; j++) {
            attackunit_t *actual = mapa[i][j];
            if (actual != NULL && actual != compartida) {
                uint32_t hash_act = fun_hash(actual);
                if (hash_act == hash_comp) {
                    compartida->references++;
                    actual->references--;
                    if (actual->references == 0) {
                        free(actual);           /* liberar SOLO si quedó a 0 */
                    }
                    mapa[i][j] = compartida;
                }
            }
        }
    }
}


/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
    uint32_t total = 0;

    for (int i = 0; i < 255; i++) {
        for (int j = 0; j < 255; j++) {
            attackunit_t* u = mapa[i][j];
            if (u != NULL) {
                uint16_t base = fun_combustible(u->clase);
                uint16_t actual = u->combustible;
                if (actual > base)
                    total += actual - base;
            }
        }
    }
    return total;
}


/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {
    attackunit_t *actual = mapa[x][y];
    if (actual)
    {
        if (actual->references > 1)
        {
            attackunit_t *nuevo = malloc(sizeof(attackunit_t));
            strcpy(nuevo->clase, actual->clase);
            nuevo->combustible = actual->combustible;
            nuevo->references = 1;
            fun_modificar(nuevo);
            actual->references--;
            mapa[x][y] = nuevo;
        }
        else
        {
            fun_modificar(actual);
        }   
    }
}
