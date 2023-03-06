// DIY Power Connector for PowerBook 500 Series
//
// François Revol, 2022-12-24

/* [Options] */

// Print the inner contact block
print_inner = true;

// Show the shield in the preview
preview_shield = true;

// Print the connector shell
print_shell = true;

// Print the connector shell on the top side rather than over the cable end
rotate_shell = true;

/* [Model parameters] */

filament_lock = false;

contact_height = 15; //TODO: prefix dsub_
pb500_pwr_conn_height = 16;
pb500_pwr_conn_diam = 6.8;
pb500_pwr_conn_pitch = 2.7;
pb500_pwr_conn_pitch_fixup = 0.2;
pb500_pwr_conn_outer_margin = 0.0;
pb500_pwr_conn_contact_margin = 0.35;
pb500_pwr_conn_key_margin = 0.1;
pb500_pwr_conn_shell_margin = 0.2;

/* [Debug] */

debug = true;

preview = true;

// Radius on the shell body
smooth = 0.3; // [0.0:0.1:0.5]

// TODO: rename avoid_supports_z
avoid_supports = true;

// TODO: IMPLEMENT
avoid_supports_y = false;

// The type of shield we'll be using
shield_type = 1; // [0: Original - anyone seen one?, 1: Cheap RCA plug]

/* [Hidden] */

//shield_margins = [0.4, 0.2];
//shield_margin = shield_margins[shield_type];


// we need more faces on such a small piece
$fa=6;
$fs=$preview?0.2:0.2;

module dsub_contact_f(wire=0, margin = 0, c=0, cavity=false) {
    color(c?"gold":0) {
        // Simplified contact but that's way enough for our need
        translate([0,0,contact_height-5.5])
            difference() {
                union() {
                    cylinder(d=1.6+margin, h=5.3);
                    translate([0,0,4.99+0.3]) cylinder(d1=1.6+margin, d2=1.1+margin, h=0.2+margin/2);
                    // Cutout for the male pin
                    if (margin) translate([0,0,0.1]) cylinder(d=1.0+margin, h=10);
                }
                if (!margin) {
                    translate([0,0,0.1]) cylinder(d=0.7, h=10);
                    translate([0,0,1]) cube([2,0.3,9], center=true);
                    translate([0,0,5.3]) cylinder(d1=0.6, d2=1.3, h=0.3);
                }
            }
        translate([0,0,contact_height-5.5-2.2])
            cylinder(d1=2+margin,d2=1.6+margin, h=2.21+margin);
        translate([0,0,contact_height-9.4+1.75-0.3])
            cylinder(d1=2.1+margin,d2=2+margin, h=0.31+margin);
        translate([0,0,contact_height-9.4+0.3])
            cylinder(d=2.1+margin, h=1.75-0.6+margin);
        translate([0,0,contact_height-9.4-margin])
            cylinder(d1=2+margin,d2=2.1+margin, h=0.31+margin);
        // Crimping clips
        difference() {
            union() {
                if (margin) {
                    translate([0,0,contact_height-9.4-1-margin/2])
                        cylinder(d1=2.15+margin, d2=2.05, h=1.1+margin/2);
                    translate([0,0,contact_height-9.4-0.5-margin/2])
                        cube([1.7,1.7,1.2+margin/2],center=true);
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
                        cylinder(d=2.1+margin, h=3.6);
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
    pitch = pb500_pwr_conn_pitch + pb500_pwr_conn_pitch_fixup;
    diam = pb500_pwr_conn_diam;
    outer_margin = pb500_pwr_conn_outer_margin;
    contact_margin = pb500_pwr_conn_contact_margin;
    contact_z_offset = 0.5;

    wire_colors = ["red", "orange", "blue", "black"];

    // pin-related placement helper
    function pin_xy(p, sx, sy, sz) = [(abs(p-1.5)>1?-1:1)*sx,(p<2?1:-1)*sy,sz];

    if (preview) {
        for (pin = [0:3])
            translate(pin_xy(pin,pitch/2,pitch/2,height - contact_height - contact_z_offset))
                dsub_contact_f(wire=8, c=wire_colors[pin]);
        // Cable
        color("LightSlateGray", 0.9) {
            translate([0,0,-34]) cylinder(d=4, h=29);
            translate([0,0,-7.5]) cylinder(d1=4, d2=6, h=2.5);
        }
        if (filament_lock)
            translate([0,0,height - 1 - 9.4 - 0.4*1.75]) rotate([0,90,0]) color("green")
                cylinder(d=1.75, h=9.5, center=true);
    }

    color("DimGray",0.7) difference() {
        union() {
            translate([0,0,height-0.3]) cylinder(d1 = diam - outer_margin, d2 = diam - outer_margin - 0.6, h = 0.3);
            cylinder(d = diam - outer_margin, h = height-0.3);
            cylinder(d1 = 9.6, d2 = 10.11, h = 0.6);
            translate([0,0,0.6]) cylinder(d = 10.11/*-2*0.5*/, h = height-6.0-0.6);
            // Pin number labels; probably too small to FDM print
            for (pin = [0:3])
                translate(pin_xy(pin,0.85*pitch,0.25*pitch,height - 0.1))
                    linear_extrude(0.35)
                        text(str(pin+1), font = "DejaVu Sans", size=0.9, halign="center", valign="center");
        }
        pb500_pwr_conn_shield(false, 0.3);
        for (pin = [0:3]) {
            translate(pin_xy(pin,pitch/2,pitch/2,height - contact_height - contact_z_offset))
                dsub_contact_f(wire=20, margin=contact_margin);
            // Chamfer for the male pin input
            translate(pin_xy(pin,pitch/2,pitch/2,height - contact_height + 0.1))
                translate([0,0,contact_height-0.6]) cylinder(d1=1.0+contact_margin, d2=1.8, h=0.6);
            // Ease contact insertion
            translate(pin_xy(pin,pitch/2+0.2,pitch/2+0.2, -0.1))
                cylinder(d1=2.2+contact_margin, d2=1.8, h=5);
        }

        // Keying
        translate([0,-0.81*diam-pb500_pwr_conn_key_margin,height - 6])
            rotate([0,0,45]) {
                linear_extrude(height=6.1) square([2.5,2.5]);
                translate([0,0,5.7]) linear_extrude(height=0.4, scale=1.2) square([2.5,2.5]);
            }

        // Locking option with a piece of filament
        if (filament_lock)
            translate([0,0,height - 1 - 9.4 - 0.4*1.75]) rotate([0,90,0]) cylinder(d=1.75+0.1, h=20, center=true);

        // Arbitrary shell keying
        translate([0,-5.5,3.99]) linear_extrude(height=2, scale=0.1) square([10,4], center=true);
        translate([0,-5,3]) cube([10,3,2], center=true);
        translate([0,-5,0]) cube([10,2,6], center=true);

        translate([0,-5.3,-0.1]) linear_extrude(height=2, scale=0.1) square([10,4], center=true);
        if (debug && $preview) rotate([0,0,-45]) cube(21);
        // speed up test
        //if (debug) cube([20,20,9], center=true);
    }
}

// The real one, at least what I measured of it
module pb500_pwr_conn_shield_official(preview=true, margin=0) {
    thickness = 0.4;
    color("Silver", 0.5) {
        translate([0,0,pb500_pwr_conn_height-10]) {
            difference() {
                cylinder(d=10.1, h=10-1.2);
                translate([0,0,-0.1]) cylinder(d=10.1-2*thickness, h=11);
                translate([0,-5,5]) cube([1.2,5,12], center=true);
            }
        }
    }
}

// A replacement shield stolen from the cheap RCA plugs
module pb500_pwr_conn_shield_rca(preview=true, margin=0) {
    thickness = 0.2;
    /*color(preview ? "Silver" : 0)*/ union() {
        translate([0,0,pb500_pwr_conn_height-7.8-1.2]) {
            difference() {
                cylinder(d=10.1+2*margin, h=7.8);
                translate([0,0,-0.1]) cylinder(d=10.1-2*thickness-2*margin, h=8);
                translate([0,-5,5]) cube([3.5-2*margin,5,12], center=true);
            }
        }
        translate([0,4.8-0.5,pb500_pwr_conn_height-7.8-1.2-7.8]) rotate([-4,0,0]) {
            difference() {
                translate([0,0,2.7/2]) cube([2.7+2*margin,thickness+4*margin,16-2.7+0.1], center=true);
                translate([0,0,-8+6.4]) rotate([-90,0,0]) cylinder(d = 1, h = 1, center=true);
            }
            translate([0,0,-8+2.7/2]) cube([5,thickness,2.7], center=true);
            for (sx=[-1,1]) {
                translate([sx*5/2,-2.4,-8+2.7/2]) difference() {
                    cube([thickness,5,2.7], center=true);
                    translate([0,-3]) rotate([sx*-60,0,0]) cube([2,6,2], center=true);
                }
            }
        }
    }
}

module pb500_pwr_conn_shield(preview=true, margin=0) {
    if (shield_type == 0)
        pb500_pwr_conn_shield_official(preview, margin);
    if (shield_type == 1)
        pb500_pwr_conn_shield_rca(preview, margin);
}

module pb500_pwr_conn_shell(preview=true) {
    shell_margin = pb500_pwr_conn_shell_margin;
    color("LightSlateGray", 0.3) {
        translate([0,0,pb500_pwr_conn_height-1.8-5.4-10]) {
            difference() {
                union() {
                    cylinder(d=11.6, h=10);
                    translate([0,0,2-20.7]) {
                        difference() {
                            minkowski() {
                                union() {
                                    difference() {
                                        intersection() {
                                            translate([0,-8,0]) cylinder(d=29-smooth, h=20.7-smooth);
                                            union() {
                                                cylinder(d=14-smooth, h=20.7-smooth);
                                                translate([0,5,20.7/2]) cube([14-smooth,10,20.7],center=true);
                                            }
                                        }
                                        translate([0,-3,49]) rotate([0,90,0]) cylinder(d=60+smooth, h=20, center=true);
                                        for (sx=[-1,1])
                                            translate([sx*14.3,0,6]) rotate([0,sx*3.5,0]) cube(15, center=true);
                                    }
                                    // Cable clip
                                    translate([0,-10,10]) intersection() {
                                        translate([0,-1,0]) cylinder(d=8.1, h=11, center=true);
                                        translate([0,1,0]) rotate([0,90,0]) cylinder(d=11, h=10, center=true);
                                    }
                                    translate([0,-10,10]) intersection() {
                                        difference() {
                                            translate([0,3.5,avoid_supports?-0.6:0]) cube([8,avoid_supports?10.4:8,avoid_supports?17.8:16], center=true);
                                            for (sz=[-1,1]) {
                                                if (avoid_supports) {
                                                    translate([0,-1,sz*12.3]) rotate([sz*40,0,0]) cube(11, center=true);
                                                } else {
                                                    translate([0,0,sz*10.3]) rotate([0,90,0]) cylinder(d=10,h=10, center=true);
                                                }
                                            }
                                        }
                                    }
                                }
                                if (smooth || !$preview) sphere(smooth);
                            }
                            // Cable clip
                            translate([0,-10,10]) {
                                translate([0,-1,0]) cylinder(d=4.5, h=20, center=true);
                                translate([0,-7,0]) rotate([0,0,45]) cube([8,8,10], center=true);
                            }
                            // DC symbol
                            translate([0,7,12]) cube([8,2,0.5], center=true);
                            for (sx=[-1,0,1])
                                translate([sx*3,7,10.5]) cube([2,2,0.5], center=true);
                        }
                    }
                }

                // XXX: depends on the shield and inner lock
                translate([0,0,5-0.1]) cylinder(d=10.1+shell_margin, h=6);

                difference() {
                    translate([0,0,1-0.1]) cylinder(d=10.1+0.1, h=11);
                    translate([0,-9.3-shell_margin,2.4]) rotate([45,0,0]) cube([10,10,6], center=true);
                }
                translate([0,0,-1]) cylinder(d=7.5, h=5);
                translate([0,3,-1]) cube([5.5,2.6,7], center=true);
                translate([0,3,-1]) cube([4.0,3.4,7], center=true);
                translate([0,0,-5]) cylinder(d1=10.1+0.2, d2=7, h=5);
                translate([0,0,-17]) cylinder(d=10.1+0.2, h=12.1);
                translate([0,0,-20]) cylinder(d=6+0.2, h=10);
                if (debug && $preview) translate([0,0,-20]) rotate([0,0,-90]) cube(31);
            }
        }
    }
}

if (print_inner) pb500_pwr_conn_inner(preview?$preview:false);
if (preview_shield && $preview) color("silver", 0.6) pb500_pwr_conn_shield($preview);
if (print_shell)
    translate($preview?[0,0,0]:[30,0,rotate_shell?6.65:20.2])
        rotate($preview?[0,0,0]:[rotate_shell?-90:0,0,rotate_shell?-90:0])
            pb500_pwr_conn_shell($preview);
