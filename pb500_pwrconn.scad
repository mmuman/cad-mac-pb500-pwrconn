// DIY Power Connector for PowerBook 500 Series
//
// François Revol, 2022-12-24

/* [Options] */

// Print the inner contact block
print_inner = true;

// Print the connector shell
print_shell = true;

/* [Model parameters] */

filament_lock = false;

contact_height = 15;
pb500_pwr_conn_height = 16;
pb500_pwr_conn_diam = 6.8;
pb500_pwr_conn_pitch = 2.7+0.05;

/* [Debug] */

debug = true;

preview = true;

/* [Hidden] */

// we need more faces on such a small piece
$fa=6;
$fs=$preview?0.2:0.1;

module dsub_contact_f(wire=0, margin = 0, c=0, cavity=false) {
    color(c?"gold":0) {
        // Simplified contact but that's way enough for our need
        translate([0,0,contact_height-5.5])
            difference() {
                union() {
                    cylinder(d=1.5+margin, h=5.0);
                    translate([0,0,4.99]) cylinder(d1=1.5+margin, d2=1+margin, h=0.5+margin/2);
                    // Cutout for the male pin
                    if (margin) translate([0,0,0.1]) cylinder(d=0.7+margin, h=10);
                }
                if (!margin) {
                    translate([0,0,0.1]) cylinder(d=0.7, h=10);
                    translate([0,0,1]) cube([2,0.3,9], center=true);
                    translate([0,0,5.3]) cylinder(d1=0.6, d2=1.1, h=0.3);
                }
            }
        translate([0,0,contact_height-5.5-2.2])
            cylinder(d1=2+margin,d2=1.5+margin, h=2.21+margin);
        translate([0,0,contact_height-9.4+1.75-0.3])
            cylinder(d1=2.1+margin,d2=2+margin, h=0.31+margin);
        translate([0,0,contact_height-9.4+0.3])
            cylinder(d=2.1+margin, h=1.75-0.6+margin);
        translate([0,0,contact_height-9.4])
            cylinder(d1=2+margin,d2=2.1+margin, h=0.31+margin);
        // Crimping clips
        difference() {
            union() {
                if (margin) {
                    translate([0,0,contact_height-9.4-1])
                        cylinder(d1=2.1+margin, d2=2-0.2, h=1.1);
                    translate([0,0,contact_height-9.4-0.5])
                        cube([1.7,1.7,1.2],center=true);
                    /* XXX: results in "Normalized tree is growing past 200000 elements."
                    for (r = [0,90]) {
                        echo(r);
                        intersection() {
                            translate([0,0,contact_height-9.4-1])
                                cylinder(d=2, h=1.1);
                            translate([0,0,contact_height-9.4]) rotate([0,0,r]) cube([2,1,3], center=true);
                        }
                    }*/
                    translate([0,0,contact_height-9.4-4.7])
                        cylinder(d=2.1+margin, h=3.8);
                }
                translate([0,0,contact_height-9.4-1.2])
                    cylinder(d1=1.4,d2=1.46, h=1.2);
                translate([0.2,0,contact_height-9.4-1.2-2])
                    cylinder(d=1.4, h=2);
                translate([0,0,contact_height-9.4-4.7+1])
                    cylinder(d1=1.6, d2=1, h=1);
                translate([0,0,contact_height-9.4-4.7])
                    cylinder(d=1.6, h=1);
            }
            if (!margin) {
                translate([0,0,contact_height-9.4-5]) cylinder(d=1, h=5);
                translate([1,0,contact_height-9.4-5]) cube([2,0.3,9], center=true);
                //translate([0,0,5.3]) cylinder(d1=0.6, d2=1.1, h=0.3);
            }
        }

        if (margin)
            translate([0,0,-10])
                cylinder(d=2.1+margin, h=10+contact_height-9.4-4.7+0.1);
    }
    // the wire
    color(c?"silver":0)
        translate([0,0,4.3]) rotate([180,0,0]) cylinder(d = 0.8+margin, h = wire + 2.2);
    color(c) {
        translate([0,0,2]) rotate([180,0,0]) cylinder(d = 1.5+margin, h = wire);
    }
}


module pb500_pwr_conn_inner(preview=true) {
    height = pb500_pwr_conn_height;
    pitch = pb500_pwr_conn_pitch;
    diam = pb500_pwr_conn_diam;
    wire_colors = ["red", "orange", "blue", "black"];

    // pin-related placement helper
    function pin_xy(p, sx, sy, sz) = [(abs(p-1.5)>1?-1:1)*sx,(p<2?1:-1)*sy,sz];

    if (preview) {
        for (pin = [0:3])
            translate(pin_xy(pin,pitch/2,pitch/2,height - contact_height - 1))
                dsub_contact_f(wire=8, c=wire_colors[pin]);
        if (filament_lock)
            translate([0,0,height - 1 - 9.4 - 0.4*1.75]) rotate([0,90,0]) color("green")
                cylinder(d=1.75, h=9.5, center=true);
    }

    color("DimGray",0.8) difference() {
        union() {
            cylinder(d = diam, h = height-0.3);
            cylinder(d = 10.1-2*0.5, h = height-8);
            translate([0,0,height-0.3]) cylinder(d1 = diam, d2 = diam - 0.6, h = 0.3);
            // Pin number labels; probably too small to FDM print
            for (pin = [0:3])
                translate(pin_xy(pin,0.85*pitch,0.25*pitch,height - 0.1))
                    linear_extrude(0.35)
                        text(str(pin+1), font = "DejaVu Sans", size=0.9, halign="center", valign="center");
        }
        for (pin = [0:3]) {
            translate(pin_xy(pin,pitch/2,pitch/2,height - contact_height - 1))
                dsub_contact_f(wire=20, margin=0.2);
            translate(pin_xy(pin,pitch/2,pitch/2,height - contact_height + 0.2))
                translate([0,0,contact_height-0.6]) cylinder(d1=0.8, d2=1.4, h=0.5);
        }

        // Keying
        translate([0,-0.8*diam,height - 6])
            rotate([0,0,45]) {
                linear_extrude(height=6.1) square([2.5,2.5]);
                translate([0,0,5.7]) linear_extrude(height=0.4, scale=1.2) square([2.5,2.5]);
            }

        // Locking option with a piece of filament
        if (filament_lock)
            translate([0,0,height - 1 - 9.4 - 0.4*1.75]) rotate([0,90,0]) cylinder(d=1.75+0.1, h=20, center=true);

        // Arbitrary shell keying
        translate([0,-5,6.99]) linear_extrude(height=1, scale=0.1) square([10,3], center=true);
        translate([0,-5,4]) cube([10,3,6], center=true);
        translate([0,-5,0]) cube([10,2,6], center=true);

        if (debug && $preview) rotate([0,0,-45]) cube(21);
    }
}

module pb500_pwr_conn_shield(preview=true) {
    color("Silver", 0.5) {
        translate([0,0,pb500_pwr_conn_height-10]) {
            difference() {
                cylinder(d=10.1, h=10-1.2);
                translate([0,0,-0.1]) cylinder(d=10.1-2*0.4, h=11);
                translate([0,-5,5]) cube([1.2,5,12], center=true);
            }
        }
    }
}
module pb500_pwr_conn_shell(preview=true) {
    m_r = 0.5;

    // Cable
    if ($preview) color("LightSlateGray", 0.9) {
        translate([0,0,-34]) cylinder(d=4, h=30);
        translate([0,0,-12]) cylinder(d1=4, d2=6, h=8);
    }

    color("LightSlateGray", 0.8) {
        translate([0,0,pb500_pwr_conn_height-1.8-5.4-10]) {
            difference() {
                union() {
                    cylinder(d=11.6, h=10);
                    translate([0,0,2-20.7]) {
                        difference() {
                            minkowski() {
                                intersection() {
                                    translate([0,-8,0]) cylinder(d=29-m_r, h=20.7);
                                    union() {
                                        cylinder(d=14-m_r, h=20.7);
                                        translate([0,5,20.7/2]) cube([14-m_r,10,20.7],center=true);
                                    }
                                }
                                sphere(0.3);
                            }
                            // DC symbol
                            translate([0,7,12]) cube([8,2,0.5], center=true);
                            for (sx=[-1,0,1])
                                translate([sx*3,7,10.5]) cube([2,2,0.5], center=true);
                        }
                    }
                }
                // XXX: depends on the shield and inner lock
                translate([0,0,-0.1]) cylinder(d=10.1+0.2, h=11);
                translate([0,0,-18]) cylinder(d=10.1+0.2, h=20.1);
                translate([0,0,-20]) cylinder(d=6+0.2, h=10);
                if (debug && $preview) translate([0,0,-20]) rotate([0,0,-90]) cube(30);
            }
        }
    }
}

if (print_inner) pb500_pwr_conn_inner(preview?$preview:false);
if ($preview) pb500_pwr_conn_shield($preview);
if (print_shell)
    translate([$preview?0:20,0,0]) pb500_pwr_conn_shell($preview);
