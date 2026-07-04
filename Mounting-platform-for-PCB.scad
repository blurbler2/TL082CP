// PCB Trägerplatte - TL082CP Audio Preamp
// Bolzen exakt auf PCB-Montagebohrungen positioniert

$fn=70;

// Platte = PCB-Größe
width   = 88.63;
length  = 75.36;
thickness = 6;

// PCB-Montagelöcher (4.5 mm)
mount_drill = 4.5;

// Schraubbolzen-Außendurchmesser
bolt_d = 8;

// Positionen der PCB-Montagelöcher (relativ zur PCB-Ecke)
hole_x1 = 6.6;
hole_x2 = 80.3;
hole_y1 = 9.5;
hole_y2 = 67.9;

difference () {
    // Basisplatte
    cube([width, length, thickness]);

    // Ausschnitt Unterseite für Zugänglichkeit
    translate([thickness*1.5, thickness*1.5, -10])
        cube([width - 3*thickness, length - 3*thickness, 20]);

    // Flache Unterseite
    translate([0, 0, -2])
        cube([width+1, length+1, 2]);
}

// Bolzen an den 4 PCB-Montagepositionen
module bolt(x, y) {
    difference() {
        translate([x, y, 1])
            cylinder(d=bolt_d, h=thickness+10);
        translate([x, y, 1.1])
            cylinder(d=mount_drill, h=thickness+10);
    }
}

bolt(hole_x1, hole_y1);
bolt(hole_x2, hole_y1);
bolt(hole_x1, hole_y2);
bolt(hole_x2, hole_y2);
