// PCB Trägerplatte - TL082CP Audio Preamp
// Angepasst an PCB: 88.63 x 75.36 mm, 4x Bohrung 4.5 mm

$fn=70;

pcb_width  = 88.63;
pcb_length = 75.36;

// Trägerplatte etwas größer als PCB
width   = 94;
length  = 81;
thickness = 6;

// PCB-Montagelöcher (M4, 4.5 mm)
mount_drill = 4.5;

// Schraubbolzen-Durchmesser
bolt_d = 8;

// Positionen der PCB-Montagelöcher (relativ zur PCB-Ecke)
hole_x1 = 6.6;
hole_x2 = 80.3;
hole_y1 = 9.5;
hole_y2 = 67.9;

// Plattenrand-Abstand (zentriert PCB auf Platte)
offset_x = (width  - pcb_width)  / 2;
offset_y = (length - pcb_length) / 2;

// Bolzenpositionen auf der Trägerplatte
bx1 = offset_x + hole_x1;
bx2 = offset_x + hole_x2;
by1 = offset_y + hole_y1;
by2 = offset_y + hole_y2;

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

bolt(bx1, by1);
bolt(bx2, by1);
bolt(bx1, by2);
bolt(bx2, by2);
