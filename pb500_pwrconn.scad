// DIY Power Connector for PowerBook 500 Series
//
// François Revol, 2022-12-24

/* [Options] */

// Print the inner contact block
print_inner = true;

// Print the connector shell
print_shell = true;

/* [Model parameters] */

contact_height = 15;
pb500_pwr_conn_height = 20;
pb500_pwr_conn_diam = 6.8;
pb500_pwr_conn_pitch = 2.7;

/* [Debug] */

debug = true;

/* [Hidden] */

// we need more faces on such a small piece
$fa=6;
$fs=0.1;

module dsub_contact_f(wire=0, margin = 0, c=0, cavity=false) {
    color(c?"gold":0) {
        translate([0,0,contact_height/2])
            difference() {
                union() {
                    cylinder(d=1.5+margin, h=5.0);
                    translate([0,0,4.99]) cylinder(d1=1.5+margin, d2=1+margin, h=0.5+margin/2);
                    if (margin) translate([0,0,0.1]) cylinder(d=0.7+margin, h=10);
                }
                if (!margin) {
                    translate([0,0,0.1]) cylinder(d=0.7, h=10);
                    translate([0,0,4]) cube([2,0.3,6], center=true);
                    translate([0,0,5.3]) cylinder(d1=0.6, d2=1.1, h=0.3);
                }
            }
        translate([0,0,contact_height/2-1])
            cylinder(d1=2+margin,d2=1.5+margin, h=1);
        translate([0,0,contact_height/2-5]) {
            translate([0,0,2.3]) cylinder(d1=2+margin,d2=1.5+margin, h=0.3);
            translate([0,0,.3]) cylinder(d=2+margin, h=2);
            cylinder(d1=1+margin,d2=2+margin, h=0.3);
        }
        
            //cube([2.54+margin,2.54+margin,contact_height], center=true);
    }
    // the wire
    color(c?"silver":0)
        translate([0,0,.1]) rotate([180,0,0]) cylinder(d = 0.8+margin, h = wire + 2.2);
    color(c) {
        translate([0,0,-2]) rotate([180,0,0]) cylinder(d = 1.5+margin, h = wire);
    }
}


module pb500_pwr_conn_inner(preview=true) {
    height = pb500_pwr_conn_height;
    pitch = pb500_pwr_conn_pitch;
    diam = pb500_pwr_conn_diam;
    wire_colors = ["red", "orange", "blue", "black"];

    // pin-related placement helper
    function pin_xy(p, sx, sy, sz) = [(abs(p-1.5)>1?-1:1)*sx,(p<2?1:-1)*sy,sz];

    color(/*"black"*/) difference() {
        union() {
            cylinder(d = diam, h = height-0.3);
            translate([0,0,height-0.3]) cylinder(d1 = diam, d2 = diam - 0.6, h = 0.3);
            // Pin number labels; probably too small to FDM print
            for (pin = [0:3])
                translate(pin_xy(pin,0.8*pitch,0.25*pitch,height - 0.1))
                    linear_extrude(0.3)
                        text(str(pin+1), font = "DejaVu Sans", size=0.8, halign="center", valign="center");
        }
        for (pin = [0:3])
            translate(pin_xy(pin,pitch/2,pitch/2,height - contact_height + 0.2)) {
                dsub_contact_f(wire=20, margin=0.2);
                translate([0,0,contact_height-0.6]) cylinder(d1=0.8, d2=1.4, h=0.5);
        }
        // Keying
        translate([0,-0.75*diam,height - 6])
            rotate([0,0,45]) {
                linear_extrude(height=6.1) square([2.5,2.5]);
                translate([0,0,5.7]) linear_extrude(height=0.4, scale=1.2) square([2.5,2.5]);
            }
        if (debug && $preview) rotate([0,0,-45]) cube(21);
    }
    if (preview) {
        for (pin = [0:3])
            translate(pin_xy(pin,pitch/2,pitch/2,height - contact_height + 0.2))
                dsub_contact_f(wire=20, c=wire_colors[pin]);
    }
}

module pb500_pwr_conn_shell(preview=true) {
    
}

if (print_inner) pb500_pwr_conn_inner($preview);
if (print_shell) pb500_pwr_conn_shell($preview);
