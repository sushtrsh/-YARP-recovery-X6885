/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>
#include <string>
#include <vector>

namespace {

void set_property(const std::string& prop, const std::string& value) {
    auto* pi = const_cast<prop_info*>(__system_property_find(prop.c_str()));
    if (pi != nullptr) {
        __system_property_update(pi, value.c_str(), value.size());
    } else {
        __system_property_add(prop.c_str(), prop.size(), value.c_str(), value.size());
    }
}

} // namespace

void vendor_load_properties() {
    const std::vector<std::string> partitions = {
        "",
        "system.",
        "vendor.",
        "odm.",
        "product.",
        "system_ext."
    };

    for (const auto& part : partitions) {
        set_property("ro.product." + part + "brand", "Infinix");
        set_property("ro.product." + part + "device", "Infinix-X6885");
        set_property("ro.product." + part + "manufacturer", "INFINIX");
        set_property("ro.product." + part + "model", "Infinix X6885");
        set_property("ro.product." + part + "name", "X6885");
        set_property("ro.product." + part + "marketname", "Infinix HOT 60 Pro");
    }

    set_property("ro.twrp.maintainer", "Made BY luv");
}
