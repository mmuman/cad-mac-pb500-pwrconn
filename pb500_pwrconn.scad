// DIY Power Connector for PowerBook 500 Series
//
// Copyright François Revol, 2022-2025
// Licenced under CC-BY-NC-SA

// WARNING: Do NOT power Vbatt (pin 1) without a current limiter circuit, it will overheat the battery!!!
// cf.
// https://tinkerdifferent.com/threads/powerbook-5xx-usb-c-pd-adapter.4243/post-36576
// https://68kmla.org/bb/index.php?threads/powerbook-power-supply-connector-520-520c-540-540c.45148/post-558172

/* [Variant] */

variant = 1; // [0:Connector,1:USB-C adapter,2:USB-C adapter + charge - UNIMPLEMENTED,3:USB-C adapter + voltmeter,4:USB-C adapter + charge + voltmeter - UNIMPLEMENTED]

/* [Options] */

// Make DC symbol hollow to see the LED through (hot glue makes for a nice light-pipe)
option_dc_symbol_hollow = false;

// Use a smaller USB-C decoy board (the one where the connector shell pins are flush with the PCB border (required unless with voltmeter variants)
option_usb_decoy_smaller = true;

// Add a way to pop the inner out for servicing
option_inner_removal_hole = true;

// Needs the proper font installed (ChicagoFLF, Symbola or Unifont Upper)
option_apple_logo = true;

/* [Print options] */

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
pb500_pwr_conn_diam = 6.9;
pb500_pwr_conn_pitch = 2.7;
pb500_pwr_conn_pitch_fixup = 0.2;
pb500_pwr_conn_outer_margin = 0.0;
pb500_pwr_conn_contact_margin = 0.35;
pb500_pwr_conn_key_margin = 0.1;
pb500_pwr_conn_shell_margin = 0.4;

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
shield_type = 1; // [0: Original - anyone seen one? - UNIMPLEMENTED, 1: Cheap RCA plug]

// BROKEN
option_angled = false;


/* [Hidden] */

//shield_margins = [0.4, 0.2];
//shield_margin = shield_margins[shield_type];


// we need more faces on such a small piece
$fa=6;
$fs=$preview?0.2:0.2;


// TODO: use NopSCADlib's
module meter_3(segColor="Red", screw_holes=true, shorter=true) {
    pcb_w = shorter ? 22.7 : 24.7;
    color("DarkGreen") difference() {
        linear_extrude(0.9) difference() {
            //import("3_7seg_pcb-Edge_Cuts.svg");
            translate([32.75, 10.55]/2) {
                square([pcb_w,10.55], center=true);
                if (screw_holes) square([32.75,5], center=true);
            }
            for (d=[0,1]) translate([28*d+2.5,5]) circle(d=3);
        }
    }
    color("White") translate([5,0.1,0.9]) cube([22.7,10.1,6]);
    color("Black") translate([5,0.1,6.9]) cube([22.7,10.1,0.1]);
    color(segColor) translate([6-3,2,6.7]) text(" 1 5. 1", font="Ataxia BRK", size=7);
    //import("3_7seg_pcb-brd.svg");
}


module usb_decoy(smaller=true, o=0) {
    d = 2.5;
    shell_th = 0.5;
    conn_offset = smaller ? 1.5 : 1.2;
    pcb_bbox = (smaller ? [9.1, 1, 15.1] : [10.9, 1.5, 16.3]) + o*[1,5,1];
    // USB-C connector
    color("silver") {
        difference() {
            union() {
                hull() {
                    for (dy = [-1,1], dx = [-1,1])
                        translate([dx*(8.8-d)/2,dy*(3.1-d)/2,o ? -5 : 0]) cylinder(d=d+o*1.2, h=6.7+(o?10+o:0));
                }
                // ground pins
                translate([0,-1,6.7-4.5/2]) cube([8.8+o, 1.5, 4.5+o], center=true);
            }
            if (o == 0) hull() {
                for (dy = [-1,1], dx = [-1,1])
                    translate([dx*(8.8-d)/2,dy*(3-d)/2,-1]) cylinder(d=d-shell_th, h=6.7);
            }
        }
    }
    //translate([0,0,6.7/2]) cube([8.8, 3.1, 6.7], center=true);
    color("green") translate([0,5*o-(3.1+pcb_bbox.y)/2,15.1/2+conn_offset]) cube(pcb_bbox, center=true);
    // TODO: components
    /* does not seem to work */
    /*
    difference() {
        translate([-20,20-0.45]) import("USB-C_devoy_001.off");
        if (smaller) difference() {
            cube([25,20,10], center=true);
            translate([3.55,0,2.5]) cube([16.5,9.1,4.2], center=true);
        }
    }
    */
}


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
                dsub_contact_f(wire= variant ? 4 : 8, c=wire_colors[pin]);
        // Cable
        if (variant == 0) color("LightSlateGray", 0.9) {
            translate([0,0,-34]) cylinder(d=4, h=29);
            translate([0,0,-7.5]) cylinder(d1=4, d2=6, h=2.5);
        }
        if (filament_lock)
            translate([0,0,height - 1 - 9.4 - 0.4*1.75]) rotate([0,90,0]) color("green")
                cylinder(d=1.75, h=9.5, center=true);

        translate([0,0,option_angled?-7:0]) rotate ([0,option_angled?-90:0,0]) {
            if (variant >= 1) {
                translate([0,0,variant < 3 ? -19.5 : -27]) usb_decoy(smaller=option_usb_decoy_smaller);
            }
            if (variant >= 3) {
                translate([10.55/2,5.8,3]) rotate([90, 90, 180]) meter_3(screw_holes=false);
            }
        }
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
        translate([0,0,pb500_pwr_conn_height-7.8-2.0]) {
            difference() {
                cylinder(d=10.2+2*margin, h=7.8);
                translate([0,0,-0.1]) cylinder(d=10.2-2*thickness-2*margin, h=8);
                translate([0,-5,5]) cube([3.1-2*margin,5,12], center=true);
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
    shell_h = (variant < 3 ? 20.7 : 30) + (option_angled ? 5 : 0);
    color("LightSlateGray", 0.3) {
        translate([0,0,pb500_pwr_conn_height-1.8-5.4-10]) {
            difference() {
                union() {
                    cylinder(d=11.6+0.5, h=10);
                    translate([0,0,option_angled?-5.5:0]) rotate ([0,option_angled?-90:0,0]) translate([0,0,2-20.7]) {
                        difference() {
                            minkowski() {
                                union() {
                                    difference() {
                                        intersection() {
                                            translate(variant < 3 ? [0, -8,0] : [0, -0.6,-8]) cylinder(d=29-smooth, h=shell_h-smooth);
                                            union() {
                                                translate([0,0,20.7-shell_h]) cylinder(d=14-smooth, h=shell_h-smooth);
                                                translate([0,12.5/2,20.7-shell_h/2]) cube([14-smooth,12.5,shell_h],center=true);
                                            }
                                        }
                                        translate(option_angled?[35,-5,20]:[0,-3,49]) rotate([0,option_angled?0:90,0]) cylinder(d=60+smooth, h=60, center=true);
                                        for (sx=[-1,1])
                                            translate([sx*14.3,0,variant < 3 ? 6 : -1.1]) rotate([0,sx*3.5,0]) cube([15,25,15], center=true);
                                        if (variant >= 1) {
                                            // Remove the whole cable clip so we can print bottom-up
                                            translate([0,smooth-10.8,5]) cube([15,10,30], center=true);
                                        }
                                    }
                                    // Cable clip
                                    if (variant == 0) translate([0,-10,10]) intersection() {
                                        translate([0,-1,0]) cylinder(d=8.1, h=11, center=true);
                                        translate([0,1,0]) rotate([0,90,0]) cylinder(d=11, h=10, center=true);
                                    }
                                    if (variant == 0) translate([0,-10,10]) intersection() {
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
                            if (variant == 0) translate([0,-10,10]) {
                                translate([0,-1,0]) cylinder(d=4.5, h=20, center=true);
                                translate([0,-7,0]) rotate([0,0,45]) cube([8,8,10], center=true);
                            }
                            // DC symbol
                            if (variant < 3) {
                                dc_offset = option_dc_symbol_hollow ? [0,5,-1.5] : [0,7.5,0];
                                translate([0,0,12]+dc_offset) cube([8,4,0.7], center=true);
                                for (sx=[-1,0,1])
                                    translate([sx*3,0,10.5]+dc_offset) cube([2,4,0.7], center=true);
                            }
                            // voltmeter
                            if (variant >= 3) {
                                translate([0,20/2,6.5]) difference() {
                                    union() {
                                        cube([10.6,20,23.5]+[1,1,1]*0.4, center=true);
                                        for (d=[0:3])
                                            cube([10.7+d/10,4-d,24+d/2]+[1,1,1]*0.4, center=true);
                                    }
                                    // Some grip to hold onto the meter PCB
                                    for (dx=[-1,1],dz=[-1,1])
                                        translate([dx*(10.55/2+0.4),2,dz*8]) rotate([90,0,-dx*3]) cylinder(d=0.8, h=8);
                                }
                            }
                        }
                    }
                }

                // XXX: depends on the shield and inner lock
                translate([0,0,5-0.1]) cylinder(d=10.1+shell_margin, h=6);

                rotate([0,0,-45*0]) difference() {
                    translate([0,0,1-0.1]) cylinder(d=10.1+shell_margin-0.1, h=11);
                    // inner lock
                    hull() for (dh=[0,1]) {
                        translate([0,-9.4-shell_margin,2.4-0.3+dh]) rotate([45,0,0]) cube([10,10,6], center=true);
                    }
                    for (a=[-1,1])
                        rotate([0,0,a*45]) translate([0,(10.1+shell_margin+0.1)/2,0]) cylinder(d=0.6, h=5);
                }
                translate([0,0,-1-10]) cylinder(d=7.5, h=5*3);

                // a way to pop the inner out for servicing
                if (option_inner_removal_hole)
                    translate([0,0,2]) rotate([90,0,0]) cylinder(d=2.8,h=10);
                // room for shield
                intersection() {
                    translate([0,3,-2]) cube([5.5,5,7], center=true);
                    translate([0,0,-5]) cylinder(d=10.1+0.1, h=11);
                }
                difference() {
                    union() {
                        translate([0,0,-5]) cylinder(d1=10.1+0.2, d2=7, h=5);
                        if (variant < 3)
                            translate([0,0,-17]) cylinder(d=10.1+0.2, h=12.1);
                    }
                    if (variant >= 1)
                        translate([0,-5.1,-10]) cube([15,7,20], center=true);
                }
                if (variant == 0) {
                    // hole for the cable
                    translate([0,0,-20]) cylinder(d=6+0.2, h=10);
                }

                if (variant >= 1) {
                    // room for the decoy in-place
                    translate([0,0,1.1 + (variant < 3 ? -19.5 : -27)]) usb_decoy(smaller=option_usb_decoy_smaller,o=0.4);
                    // room for decoy insertion
                    if (variant < 3) for (d = [10,13,16])
                        translate([0,1,d-19.5]) usb_decoy(smaller=option_usb_decoy_smaller,o=0.4);
                    else
                        translate([0,1.8,-22]) rotate([-20,0,0]) usb_decoy(smaller=option_usb_decoy_smaller,o=0.1);
                    // room for solder joints and wires under the PCB
                    translate([0,-3,(variant < 3 ? -19.5 : -27)+15.5]) cube([9.5,3,4], center=true);

                    // avoid supports
                    for (dx = [-1,1])
                        translate([dx*1.5,-1.2,-3.2]) rotate([0,0,45]) cube(4.2);
                    // Remove the whole cable clip so we can print bottom-up
                    translate([0,-10.75,-5]) cube([15,10,50], center=true);
                    label_text = (variant % 2) ? "15V 1.5A" : "15V 2.5A";
                    translate([0,-5.3,0]) rotate([90,90,0]) linear_extrude(0.7) text(label_text, size=3.2, valign="center");
                    // cute but too small, makes a lot of print errors
                    //translate([2.5,-5.5,-1]) rotate([90,90,0]) linear_extrude(0.7) text("PowerBook 5xx", size=2.5, valign="center");
                }
                if (option_apple_logo && (variant >= 3)) {
                    translate([0,7,-26.5])
                        rotate([0,180,0]) linear_extrude(height=0.5)
                            text("\U01F34E", font="ChicagoFLF,Symbola,Unifont Upper", valign="center", halign="center", size=5);
                }

                if (debug && $preview) translate([0,0,-30]) rotate([0,0,0]) cube(41);
            }
        }
    }
}

if (print_inner) pb500_pwr_conn_inner(preview?$preview:false);
if (preview_shield && $preview) color("silver", 0.6) pb500_pwr_conn_shield($preview);
if (print_shell)
    translate($preview?[0,0,0]:[20,0,rotate_shell?(variant?5.75:6.65):(variant<3?20.2:28.185)])
        rotate($preview?[0,0,0]:[rotate_shell?(variant?90:-90):0,0,rotate_shell?-90:0])
            pb500_pwr_conn_shell($preview);
//if ($preview) translate([10,0,0]) usb_decoy();