// DIY Power Connector for PowerBook 500 Series
//
// François Revol, 2022-12-24

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

// abandoned: it's too larged to fit 4 of them.
module dupont_1x1_f(wire=0, margin = 0, c=0) {
    dupont_height = 15;
    color(c?"black":0)
        translate([0,0,dupont_height/2])
            cube([2.54+margin,2.54+margin,dupont_height], center=true);
    color(c) {
        translate([0,0,.1]) rotate([180,0,0]) cylinder(d = 1.5+margin, h = wire);
    }
}

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
    color(/*"black"*/) difference() {
        union() {
            cylinder(d = diam, h = height-0.3);
            translate([0,0,height-0.3]) cylinder(d1 = diam, d2 = diam - 0.6, h = 0.3);
        }
        for (pin = [0:3])
            translate([(pin%2)?((pin>1?1:-1)*sqrt(pitch^2/2)):0,(pin%2==0)?((pin>1?1:-1)*sqrt(pitch^2/2)):0,height - contact_height + 0.2]) {
                dsub_contact_f(wire=20, margin=0.2);
                translate([0,0,contact_height-0.6]) cylinder(d1=0.8, d2=1.4, h=0.5);
        }
        
        translate([diam/6,-diam/6-2.5,height - 10 + 0.01])
            cube([2.5,2.5,10]);
        if (debug && $preview) cube(21);
    }
    if (preview) {
        for (pin = [0:3])
            translate([(pin%2)?((pin>1?1:-1)*sqrt(pitch^2/2)):0,(pin%2==0)?((pin>1?1:-1)*sqrt(pitch^2/2)):0,height - contact_height + 0.2])
                dsub_contact_f(wire=20, c=wire_colors[pin]);
    }
}

pb500_pwr_conn_inner($preview);
