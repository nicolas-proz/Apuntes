#include "ej4b.h"

#include <string.h>

// OPCIONAL: implementar en C
void invocar_habilidad(void* carta_generica, char* habilidad) {
	card_t* carta = carta_generica;
	uint16_t len = carta->__dir_entries;
	for (uint16_t i = 0; i < len; i++)
	{
		directory_entry_t *actual = carta->__dir[i];
		if (strcmp(actual->ability_name, habilidad) == 0)
		{
			ability_function_t* f = (ability_function_t*) actual->ability_ptr;
			f(carta); 
		}	
	}
	if (carta->__archetype)
	{
		invocar_habilidad(carta->__archetype, habilidad);
	}
}
