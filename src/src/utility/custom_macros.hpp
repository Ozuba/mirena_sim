#ifndef CUSTOM_MACROS_HPP
#define CUSTOM_MACROS_HPP

// Property defining macros

// Bind a read-write property. See BIND_PROPERTY_R and BIND_PROPERTY_W for other options
#define BIND_PROPERTY_RW(class_name, var_name, var_type) \
    ClassDB::bind_method(D_METHOD("get_" #var_name), &class_name::get_##var_name); \
    ClassDB::bind_method(D_METHOD("set_" #var_name, "_" #var_name), &class_name::set_##var_name); \
    ADD_PROPERTY(PropertyInfo(var_type, #var_name), "set_" #var_name, "get_" #var_name)


// Bind a read only property. See BIND_PROPERTY_WR and BIND_PROPERTY_W for other options
#define BIND_PROPERTY_R(class_name, var_name, var_type) \
    ClassDB::bind_method(D_METHOD("get_" #var_name), &class_name::get_##var_name); 
    


// Bind a write only property. See BIND_PROPERTY_WR and BIND_PROPERTY_R for other options
#define BIND_PROPERTY_W(class_name, var_name, var_type) \
    ClassDB::bind_method(D_METHOD("set_" #var_name, "_" #var_name), &class_name::set_##var_name); 
    

#endif