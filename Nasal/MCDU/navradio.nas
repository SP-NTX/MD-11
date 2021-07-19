# McDonnell Douglas MD-11 MCDU
# Copyright (c) 2021 Josh Davidson (Octal450)

var NavRadio = {
	new: func(n) {
		var m = {parents: [NavRadio]};
		
		m.id = n;
		
		m.Display = {
			arrow: 0,
			
			CFont: [FONT.normal, FONT.normal, FONT.normal, FONT.normal, FONT.normal, FONT.normal],
			C1: "",
			C1S: "",
			C2: "",
			C2S: "",
			C3: "",
			C3S: "",
			C4: "",
			C4S: "",
			C5: "",
			C5S: "",
			C6: "",
			C6S: "PRESELECT",
			
			LFont: [FONT.normal, FONT.normal, FONT.normal, FONT.normal, FONT.normal, FONT.normal],
			L1: "",
			L1S: "VOR1/CRS",
			L2: "",
			L2S: "",
			L3: "",
			L3S: "ADF1",
			L4: "",
			L4S: "ILS/CRS",
			L5: "",
			L5S: "",
			L6: "[   ]/[   ]",
			L6S: "",
			
			pageNum: "",
			
			RFont: [FONT.normal, FONT.normal, FONT.normal, FONT.normal, FONT.normal, FONT.normal],
			R1: "",
			R1S: "VOR2/CRS",
			R2: "",
			R2S: "",
			R3: "",
			R3S: "ADF2",
			R4: "",
			R4S: "",
			R5: "",
			R5S: "",
			R6: "[   ]/[   ]",
			R6S: "",
			
			simple: 1,
			title: "NAV RADIO",
		};
		
		m.group = "fmc";
		m.name = "navRadio";
		m.nextPage = "none";
		m.scratchpad = "";
		m.scratchpadSplit = nil;
		
		m.Value = {
			adfSet: [0, 0],
			navCrsSet: [0, 0, 0],
			navSet: [0, 0, 0],
		};
		
		return m;
	},
	reset: func() {
		me.setup();
	},
	setup: func() {
		me.Value.adfSet[0] = 0;
		me.Value.adfSet[1] = 0;
		me.Value.navCrsSet[0] = 0;
		me.Value.navCrsSet[1] = 0;
		me.Value.navCrsSet[2] = 0;
		me.Value.navSet[0] = 0;
		me.Value.navSet[1] = 0;
		me.Value.navSet[2] = 0;
	},
	loop: func() {
		if (me.Value.navSet[0]) {
			if (me.Value.navCrsSet[0]) {
				me.Display.L1 = sprintf("%5.2f", math.round(pts.Instrumentation.Nav.Frequencies.selectedMhz[0].getValue(), 0.01)) ~ "/" ~ sprintf("%03d", pts.Instrumentation.Nav.Radials.selectedDeg[0].getValue()) ~ "g";
			} else {
				me.Display.L1 = sprintf("%5.2f", math.round(pts.Instrumentation.Nav.Frequencies.selectedMhz[0].getValue(), 0.01)) ~ "/[ ]g";
			}
		} else {
			me.Display.L1 = "[  ]/[ ]g";
		}
		
		if (me.Value.navSet[1]) {
			if (me.Value.navCrsSet[1]) {
				me.Display.R1 = sprintf("%5.2f", math.round(pts.Instrumentation.Nav.Frequencies.selectedMhz[1].getValue(), 0.01)) ~ "/" ~ sprintf("%03d", pts.Instrumentation.Nav.Radials.selectedDeg[1].getValue()) ~ "g";
			} else {
				me.Display.R1 = sprintf("%5.2f", math.round(pts.Instrumentation.Nav.Frequencies.selectedMhz[1].getValue(), 0.01)) ~ "/[ ]g";
			}
		} else {
			me.Display.R1 = "[  ]/[ ]g";
		}
		
		if (me.Value.navSet[2]) {
			if (me.Value.navCrsSet[2]) {
				me.Display.L4 = sprintf("%5.2f", math.round(pts.Instrumentation.Nav.Frequencies.selectedMhz[2].getValue(), 0.01)) ~ "/" ~ sprintf("%03d", pts.Instrumentation.Nav.Radials.selectedDeg[2].getValue()) ~ "g";
			} else {
				me.Display.L4 = sprintf("%5.2f", math.round(pts.Instrumentation.Nav.Frequencies.selectedMhz[2].getValue(), 0.01)) ~ "/[ ]g";
			}
		} else {
			me.Display.L4 = "[  ]/[ ]g";
		}
		
		if (me.Value.adfSet[0]) {
			me.Display.L3 = sprintf("%4.1f", math.round(pts.Instrumentation.Adf.Frequencies.selectedKhz[0].getValue(), 0.1));
		} else {
			me.Display.L3 = "[  ]";
		}
		
		if (me.Value.adfSet[1]) {
			me.Display.R3 = sprintf("%4.1f", math.round(pts.Instrumentation.Adf.Frequencies.selectedKhz[1].getValue(), 0.1));
		} else {
			me.Display.R3 = "[  ]";
		}
	},
	insertAdf: func(n) {
		if (mcdu.unit[me.id].stringDecimalLengthInRange(0, 1) and mcdu.unit[me.id].stringLengthInRange(3, 6) and !mcdu.unit[me.id].stringContains("-")) {
			if (me.scratchpad >= 190 and me.scratchpad <= 1750) {
				pts.Instrumentation.Adf.Frequencies.selectedKhz[n].setValue(me.scratchpad);
				me.Value.adfSet[n] = 1;
				mcdu.unit[me.id].scratchpadClear();
			} else {
				mcdu.unit[me.id].setMessage("ENTRY OUT OF RANGE");
			}
		} else {
			mcdu.unit[me.id].setMessage("FORMAT ERROR");
		}
	},
	insertNav: func(n) {
		if (find("/", me.scratchpad) != -1) {
			me.scratchpadSplit = split("/", me.scratchpad);
		} else {
			me.scratchpadSplit = [me.scratchpad, ""];
		}
		
		if (mcdu.unit[me.id].stringContains("-")) {
			mcdu.unit[me.id].setMessage("FORMAT ERROR");
			return;
		}
		
		if (size(me.scratchpadSplit[0]) > 0) { # Frequency
			if (mcdu.unit[me.id].stringLengthInRange(3, 6, me.scratchpadSplit[0]) and mcdu.unit[me.id].stringDecimalLengthInRange(0, 2, me.scratchpadSplit[0])) {
				if (n == 2) { # ILS
					if (me.scratchpadSplit[0] < 108 or me.scratchpadSplit[0] > 111.95) {
						mcdu.unit[me.id].setMessage("ENTRY OUT OF RANGE");
						return;
					}
				} else { # VOR
					if (me.scratchpadSplit[0] < 108 or me.scratchpadSplit[0] > 117.95) {
						mcdu.unit[me.id].setMessage("ENTRY OUT OF RANGE");
						return;
					}
				}
			} else {
				mcdu.unit[me.id].setMessage("FORMAT ERROR");
				return;
			}
		}
		
		if (size(me.scratchpadSplit[1]) > 0) { # Course
			if (mcdu.unit[me.id].stringLengthInRange(1, 3, me.scratchpadSplit[1]) and mcdu.unit[me.id].stringIsNumber(me.scratchpadSplit[1]) and !mcdu.unit[me.id].stringContains(".", me.scratchpadSplit[1])) {
				if (me.scratchpadSplit[1] == 0) {
					me.scratchpadSplit[1] = 360;
				}
				
				if (me.scratchpadSplit[1] < 1 or me.scratchpadSplit[1] > 360) {
					mcdu.unit[me.id].setMessage("ENTRY OUT OF RANGE");
					return;
				}
			} else {
				mcdu.unit[me.id].setMessage("FORMAT ERROR");
				return;
			}
		}
		
		if (size(me.scratchpadSplit[0]) > 0) {
			pts.Instrumentation.Nav.Frequencies.selectedMhz[n].setValue(me.scratchpadSplit[0]);
			me.Value.navSet[n] = 1;
		}
		if (size(me.scratchpadSplit[1]) > 0) {
			pts.Instrumentation.Nav.Radials.selectedDeg[n].setValue(me.scratchpadSplit[1]);
			me.Value.navCrsSet[n] = 1;
		}
		mcdu.unit[me.id].scratchpadClear();
	},
	softKey: func(k) {
		me.scratchpad = mcdu.unit[me.id].scratchpad;
		
		if (mcdu.unit[me.id].scratchpadState() == 2) {
			if (k == "l1") {
				me.insertNav(0);
			} else if (k == "l3") {
				me.insertAdf(0);
			} else if (k == "l4") {
				me.insertNav(2);
			} else if (k == "r1") {
				me.insertNav(1);
			} else if (k == "r3") {
				me.insertAdf(1);
			} else {
				mcdu.unit[me.id].setMessage("NOT ALLOWED");
			}
		} else if (mcdu.unit[me.id].scratchpadState() == 0) {
			if (k == "l1") {
				if (me.Value.navSet[0]) {
					me.Value.navSet[0] = 0;
					me.Value.navCrsSet[0] = 0;
					pts.Instrumentation.Nav.Frequencies.selectedMhz[0].setValue(0);
					pts.Instrumentation.Nav.Radials.selectedDeg[0].setValue(0);
					mcdu.unit[me.id].scratchpadClear();
				} else {
					mcdu.unit[me.id].setMessage("NOT ALLOWED");
				}
			} else if (k == "l3") {
				if (me.Value.adfSet[0]) {
					me.Value.adfSet[0] = 0;
					pts.Instrumentation.Adf.Frequencies.selectedKhz[0].setValue(0);
					mcdu.unit[me.id].scratchpadClear();
				} else {
					mcdu.unit[me.id].setMessage("NOT ALLOWED");
				}
			} else if (k == "l4") {
				if (me.Value.navSet[2]) {
					me.Value.navSet[2] = 0;
					me.Value.navCrsSet[2] = 0;
					pts.Instrumentation.Nav.Frequencies.selectedMhz[2].setValue(0);
					pts.Instrumentation.Nav.Radials.selectedDeg[2].setValue(0);
					mcdu.unit[me.id].scratchpadClear();
				} else {
					mcdu.unit[me.id].setMessage("NOT ALLOWED");
				}
			} else if (k == "r1") {
				if (me.Value.navSet[1]) {
					me.Value.navSet[1] = 0;
					me.Value.navCrsSet[1] = 0;
					pts.Instrumentation.Nav.Frequencies.selectedMhz[1].setValue(0);
					pts.Instrumentation.Nav.Radials.selectedDeg[1].setValue(0);
					mcdu.unit[me.id].scratchpadClear();
				} else {
					mcdu.unit[me.id].setMessage("NOT ALLOWED");
				}
			} else if (k == "r3") {
				if (me.Value.adfSet[1]) {
					me.Value.adfSet[1] = 0;
					pts.Instrumentation.Adf.Frequencies.selectedKhz[1].setValue(0);
					mcdu.unit[me.id].scratchpadClear();
				} else {
					mcdu.unit[me.id].setMessage("NOT ALLOWED");
				}
			} else {
				mcdu.unit[me.id].setMessage("NOT ALLOWED");
			}
		} else {
			mcdu.unit[me.id].setMessage("NOT ALLOWED");
		}
	},
};
