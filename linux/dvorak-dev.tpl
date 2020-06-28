
/////////////////////////////// dvorak-dev START
//
// Developer Dvorak layout.
//
// Author: Pascal Morin <pm98zz.c@gmail.com>
// Source: github
// 
// Based on the programmer Dvorak layout, by Roland Kaufmann.
// http://www.kaufmann.no/roland/dvorak/
//
///////////////////////////////
partial alphanumeric_keys 
xkb_symbols "dvorak-dev" {
    name[Group1] = "English (developer Dvorak)";
    key.type[Group1]="EIGHT_LEVEL";
    
/////////////////////////////// MATRIX

    include "level5(modifier_mapping)"
    include "level3(ralt_switch)"
    include "level5(caps_switch)"
    include "shift(both_shiftlock)"

};
/////////////////////////////// dvorak-dev END

