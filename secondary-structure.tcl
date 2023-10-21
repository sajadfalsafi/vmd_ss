#
#                                   secondary-structure Plug-in v1.0
#
# A GUI interface for Calculate secondary structure in pdb file and during simulation
#
#
# Authors:
#      Sajad Falsafi Zadeh, sajad.falsafi@yahoo.com
#      Zahra Karimi, z.karimi20@yahoo.com
#
# Wed Feb 01 13:57:18 +0330 2012
# [clock format [clock scan now]]

package provide secondary_structure 1.0

namespace eval ::structure:: {
	namespace export structure_gui
	variable currentmol none
	variable selection ""
	variable logtext
	variable chartthreed 1
	variable chartpie 0
	variable eachres 0
	variable varpercentage 0
	variable allframes 1
}


proc ::structure::structure_gui {} {
	
	variable win                                                                               
	variable currentmol none
	variable selection "protein"
	variable logtext 
	variable chartthreed  
	variable chartpie
	variable eachres
	variable varpercentage
	variable mollist "Select Molecule"
	variable menumol
	variable allframes
	variable firstframe "First Frame"
	variable lastframe "Last Frame"
	variable OutputFilePdb
	variable OutputFileDcd
	variable outputPdb
	variable outputDcd
	variable sstype "all"
  
	trace add variable [namespace current]::currentmol write [namespace code {
		variable currentmol
		variable menumol
		if { ! [catch { molinfo $currentmol get name } name ] } {
			set menumol "$currentmol: $name"
# #################################################################################
set numberf [molinfo $currentmol get numframes]
if {$numberf>"1"} {


	destroy $win.pdb
	destroy $win.sel

	labelframe $win.sel -bd 2 -relief ridge -text "during simulation" -padx 1m -pady 1m
	set f [frame $win.sel.all]
	set row 0
	grid [label $f.labelframe -text "Frames :" ] \
    -row $row -column 0 -columnspan 3 -sticky w	
	grid [checkbutton $f.allframes -text "All frames" \
    -variable [namespace current]::guiallframes -command ::structure::activate_frame] \
    -row $row  -column 1 -columnspan 1 -sticky w
#	grid [label $f.labelfirst -text "First:"] \
    -row $row -column 2 -columnspan 1 -sticky w
	grid [entry $f.entryfirst -width 9 -highlightthickness 3 \
    -textvariable [namespace current]::firstframe -state disable] \
    -row $row -column 2 -columnspan 1 -sticky s	
#	grid [label $f.labellast -text "Last:"] \
    -row $row -column 3 -columnspan 1 -sticky w
	grid [entry $f.entrylast -width 9 -highlightthickness 3 \
    -textvariable [namespace current]::lastframe -state disable] \
    -row $row -column 3 -columnspan 1 -sticky s
	incr row
	grid [label $f.labelplot -text "% SS: " -padx 2 -pady 3] \
    -row $row -column 0 -sticky w
	tk_optionMenu $f.mss ::structure::sstype all T E B H G I C none
	grid $f.mss -row $row -column 1 -sticky w -pady 5
	incr row
#	grid [label $f.percen -text "" -padx 2 -pady 3] \
    -row $row -column 0 -sticky w
	grid [checkbutton $f.percentage -text "% SS residue: " \
	-variable [namespace current]::guipercentage ] \
    -row $row  -column 0 -sticky w	
	pack $f -side top -padx 0 -pady 0 -expand 1 -fill none -anchor w
	incr row 
	set f [frame $win.sel.out]
	grid [label $f.labeloutput -text "Output File:" -anchor w] \
	-row $row -column 0 -sticky w
	grid [entry $f.entryoutput -width 35 -highlightthickness 3 -textvariable [namespace current]::outputDcd ] \
	-row $row -column 1 -sticky w
	grid [button $f.savebutton -width 7 -text "save as" -cursor hand2 -command [namespace code OutputFileDcd] -padx 11] \
	-row $row -column 2 -sticky w
	pack $f -side top -padx 0 -pady 0 -expand 1 -anchor w
	incr row
	set f [frame $win.sel.run]
	button $f.buttonrun -text "Calculate" -width 10 -padx 2 -pady 2 -cursor hand2 -command { ::structure::structure_dcd }  
	pack $f 
	pack $f.buttonrun
	set f [frame $win.sel.outl]
	set row 0
	grid [label $f.labeltext -text "Output :"] \
    -row $row -column 0 -pady 5 -sticky w
	pack $f -anchor w
	set f [frame $win.sel.log]
	set row 0
	text $f.logtext -width 53 -height 8 -yscrollcommand "$f.srl_y set" -highlightthickness 3 
	scrollbar $f.srl_y -command "$f.logtext yview" -orient v  
	grid $f.logtext -row 1 -column 1
	grid $f.srl_y -row 1 -column 2 -sticky ns
	pack $f -side top -padx 0 -pady 0 -expand 1 -fill none
	pack $win.sel -side top -pady 5 -padx 3 -fill x -anchor w	

	
	
	} elseif {$numberf=="1"} {
	
	variable guieachres $eachres
	
	destroy $win.pdb
	destroy $win.sel
	
	
	labelframe $win.pdb -bd 2 -relief ridge -text "in PDB File" -padx 1m -pady 1m
	set f [frame $win.pdb.all]
	set row 0	
	grid [label $f.chart -text "Chart :" -padx 2 -pady 3] \
    -row $row -column 0 -columnspan 1 -sticky w	
	grid [checkbutton $f.3dchart -text "3-D chart" \
	-variable [namespace current]::gui3dchart ] \
    -row $row -column 1 -columnspan 1 -sticky w	
	grid [checkbutton $f.piechart -text "Pie chart" \
	-variable [namespace current]::guipiechart ] \
    -row $row -column 2 -columnspan 1 -sticky w
    incr row
	grid [label $f.percen -text "SS each residue:" -padx 2 -pady 7] \
    -row $row -column 0 -sticky w	
	grid [checkbutton $f.eachresid -text "" \
	-variable [namespace current]::guieachres ] \
    -row $row  -column 1 -sticky w	
	incr row
	pack $f -side top -padx 0 -pady 0 -expand 1 -fill none -anchor w
	set f [frame $win.pdb.out]
	grid [label $f.labeloutput -text "Output File:" -anchor w] \
	-row $row -column 0 -sticky w
	grid [entry $f.entryoutput -width 35 -highlightthickness 3 -textvariable [namespace current]::outputPdb ] \
	-row $row -column 1 -sticky w
	grid [button $f.savebutton -width 7 -text "save as" -cursor hand2 -command [namespace code OutputFilePdb] -padx 11] \
	-row $row -column 3 -sticky w
	pack $f -side top -padx 0 -pady 0 -expand 1 -anchor w
	incr row
	set f [frame $win.pdb.run]
	button $f.buttonrun -text "Calculate" -width 10 -padx 2 -pady 2 -cursor hand2 -command { ::structure::secondary_pdb }  
	pack $f
	pack $f.buttonrun
	set f [frame $win.pdb.outl]
	set row 0
	grid [label $f.labeltext -text "Output :"] \
    -row $row -column 0 -pady 5 -sticky w
	pack $f -anchor w
	set f [frame $win.pdb.log]
	set row 0	
	text $f.logtext -width 53 -height 8 -yscrollcommand "$f.srl_y set" -highlightthickness 3 
	scrollbar $f.srl_y -command "$f.logtext yview" -orient v  
	grid $f.logtext -row $row -column 1
	grid $f.srl_y -row $row -column 2 -sticky ns
	pack $f -side top -padx 0 -pady 0 -expand 1 -fill none
	pack $win.pdb -side top -pady 5 -padx 3 -fill x -anchor w		
	
	
	
	
	
	} else {







}


	} else {
		set menumol $currentmol
		}
  # } ]
	set currentmol $mollist
	variable molid 0

######## structure gui ########   
	if {[winfo exists .structuregui]} {
		wm deiconify $win
		return
	}
	set win [toplevel ".structuregui"]
	wm title $win "VMD-SS"
	wm resizable $win 0 0

	variable gui3dchart $chartthreed 
	variable guipiechart $chartpie
	variable guiallframes $allframes
	variable guipercentage $varpercentage

	################ menu ###################
	menu $win.menu -tearoff 0
    menu $win.menu.file -tearoff 0
    menu $win.menu.help -tearoff 0
    $win.menu add cascade -label "File   " -menu $win.menu.file -underline 0
    $win.menu add cascade -label "Help" -menu $win.menu.help -underline 0

    #File menu
    $win.menu.file add command -label "Reset" \
		-command "[namespace current]::ResetPlugin"
	$win.menu.file add command -label "Save Log" \
		-command "[namespace current]::SaveLog"
    #Help menu
    $win.menu.help add command -label "Help" \
        -command "vmd_open_url http://www.bioinfoservices.ir/" 
    $win.menu.help add command -label "About us" \
	    -command  [namespace code {tk_messageBox -parent $win -type ok -title "Authors" -message "Sajad Falsafi & Zahra Karimi" } ]
    $win configure -menu $win.menu
	

	############## frame for selection #############
	labelframe $win.mol -bd 2 -relief ridge -text "Selection" -padx 1m -pady 1m
	set f [frame $win.mol.all]
	set row 0
	grid [label $f.mollable -text "Molecule: "] \
    -row $row -column 0 -columnspan 3 -sticky w
	grid [menubutton $f.mol -textvar [namespace current]::menumol \
    -menu $f.mol.menu -relief raised -cursor hand2 ] \
    -row $row -column 1 -columnspan 3 -sticky w 
	menu $f.mol.menu -tearoff no
	incr row
	grid [label $f.sellabel1 -text "Selection : "] \
    -row $row -column 0 -pady 15 -sticky w
	grid [entry $f.sel1 -width 45 -highlightthickness 3 \
    -textvariable [namespace current]::selection] \
    -row $row -column 1 -columnspan 3 -sticky w
	incr row
	fill_mol_menu $f.mol.menu
	trace add variable ::vmd_initialize_structure write [namespace code "
    fill_mol_menu $f.mol.menu
	# " ]
	pack $f -side top -padx 0 -pady 5 -expand 1 -fill x
	set f [frame $win.mol.n]
	set row 0
	grid [label $f.label1 -text "                      (chain A and resid 1 to 10); (protein and resid 18 to 23)"] \
    -row $row -column 0 -sticky w
#	incr row
#	grid [label $f.label11 -text "                      (protein and resid 18 to 23)"] \
    -row $row -column 0 -pady 5 -sticky w
	incr row
	grid [label $f.label2 -text "Note: Different display option depend on the type of the PDB or trajectory."] \
    -row $row -column 0 -pady 5 -sticky w
	pack $f -anchor w 
	
	pack $win.mol -side top -pady 5 -padx 3 -fill x -anchor w 
	
	
}

# Adapted from pmepot gui
proc ::structure::fill_mol_menu {name} {
	variable molid
	variable currentmol
	variable mollist0
	
	$name delete 0 end
	set molList ""
	foreach mm [array names ::vmd_initialize_structure] {
		if { $::vmd_initialize_structure($mm) != 0} {
      lappend molList $mm
      $name add radiobutton -variable [namespace current]::currentmol \
        -value $mm -label "$mm [molinfo $mm get name]"
		}
	}
}


proc ::structure::structure_dcd {} {
	variable win
	variable currentmol
	variable selection
	variable logtext
	variable gui3dchart
	variable guipiechart
	variable guipercentage
	variable sstype
	variable guiallframes
	variable firstframe
	variable lastframe
	variable outputDcd
	

	
	# set log file
	if {$outputDcd == ""} {
		set logdcd "stdout"
	} else {
		set logdcd [open "$outputDcd" w]
	}
	if {$guiallframes!=1} {
		if {$firstframe==""} {
			tk_messageBox -type ok -title "Select Frame" -message "please inter the First Frame"
			return
		} elseif {$lastframe==""} {
			tk_messageBox -type ok -title "Select Frame" -message "please inter the Last Frame"
			return
		}
	}
		
   	if {$sstype!="none"} {
		if {$guiallframes==1} {
			set nf [molinfo $currentmol get numframes]
			for {set i 0} { $i<$nf } {incr i} {
			animate goto $i
			display update ui
			mol ssrecalc $currentmol

			set fulllist [set ss [[atomselect $currentmol "$selection and alpha"] get structure]]
			set all [llength $fulllist]
			set perT [expr {(([llength [lsearch -all $fulllist T]]+0.)/$all)*100}]
			set perE [expr {(([llength [lsearch -all $fulllist E]]+0.)/$all)*100}]
			set perB [expr {(([llength [lsearch -all $fulllist B]]+0.)/$all)*100}]
			set perH [expr {(([llength [lsearch -all $fulllist H]]+0.)/$all)*100}]
			set perG [expr {(([llength [lsearch -all $fulllist G]]+0.)/$all)*100}]
			set perI [expr {(([llength [lsearch -all $fulllist I]]+0.)/$all)*100}]
			set perC [expr {(([llength [lsearch -all $fulllist C]]+0.)/$all)*100}]
			lappend framecount $i
			lappend tcount $perT
			lappend ecount $perE
			lappend bcount $perB
			lappend hcount $perH
			lappend gcount $perG
			lappend icount $perI
			lappend ccount $perC
			}
		}

		if {$guiallframes==0} {
			for {set i $firstframe} { $i <= $lastframe } {incr i} {
				animate goto $i
				display update ui
				mol ssrecalc $currentmol
				set fulllist [set ss [[atomselect $currentmol "$selection and alpha"] get structure]]
				set all [llength $fulllist]
				set perT [expr {(([llength [lsearch -all $fulllist T]]+0.)/$all)*100}]
				set perE [expr {(([llength [lsearch -all $fulllist E]]+0.)/$all)*100}]
				set perB [expr {(([llength [lsearch -all $fulllist B]]+0.)/$all)*100}]
				set perH [expr {(([llength [lsearch -all $fulllist H]]+0.)/$all)*100}]
				set perG [expr {(([llength [lsearch -all $fulllist G]]+0.)/$all)*100}]
				set perI [expr {(([llength [lsearch -all $fulllist I]]+0.)/$all)*100}]
				set perC [expr {(([llength [lsearch -all $fulllist C]]+0.)/$all)*100}]
				lappend framecount $i
				lappend tcount $perT
				lappend ecount $perE
				lappend bcount $perB
				lappend hcount $perH
				lappend gcount $perG
				lappend icount $perI
				lappend ccount $perC
			}
		}
		
	# plot {T #469696} {E #FFFF64} {B #B4B400} {H #E182E1} {G #FF99FF} {I #ED1818} {C #FFFFFF}
		set title [format "%s %s %s: %s" Molecule $currentmol, [molinfo $currentmol get name]  "Secondary Structure vs. Frame"]
		set plothandle [multiplot -title $title -xlabel "Frame " -ylabel "Percentage SS" -ymin 0 -ymax 100]
		if {$sstype == "T"} {
			$plothandle add $framecount $tcount -lines -linewidth 1 -linecolor #469696 -marker point -legend "Turn"
		} 
		if {$sstype == "E"} { 
			$plothandle add $framecount $ecount -lines -linewidth 1 -linecolor #FFFF64 -marker point -legend "Extended conformation"
		}
		if {$sstype == "B"} { 
			$plothandle add $framecount $bcount -lines -linewidth 1 -linecolor #B4B400 -marker point -legend "Isolated bridge"
		}
		if {$sstype == "H"} { 
			$plothandle add $framecount $hcount -lines -linewidth 1 -linecolor #E182E1 -marker point -legend "Alpha helix"
		}	
		if {$sstype == "G"} { 
			$plothandle add $framecount $gcount -lines -linewidth 1 -linecolor #FF99FF -marker point -legend "3-10 helix"
		}	
		if {$sstype == "I"} { 
			$plothandle add $framecount $icount -lines -linewidth 1 -linecolor #ED1818 -marker point -legend "Pi-helix"
		}	
		if {$sstype == "C"} { 
			$plothandle add $framecount $ccount -lines -linewidth 1 -linecolor #FFFFFF -marker point -legend "Coil (Other structure)"
		}		
		if {$sstype == "all"} {
			$plothandle add $framecount $tcount -lines -linewidth 1 -linecolor #469696 -marker point -legend "Turn"
			$plothandle add $framecount $ecount -lines -linewidth 1 -linecolor #FFFF64 -marker point -legend "Extended conformation"
			$plothandle add $framecount $bcount -lines -linewidth 1 -linecolor #B4B400 -marker point -legend "Isolated bridge"
			$plothandle add $framecount $hcount -lines -linewidth 1 -linecolor #E182E1 -marker point -legend "Alpha helix"
			$plothandle add $framecount $gcount -lines -linewidth 1 -linecolor #FF99FF -marker point -legend "3-10 helix"
			$plothandle add $framecount $icount -lines -linewidth 1 -linecolor #ED1818 -marker point -legend "Pi-helix"
			$plothandle add $framecount $ccount -lines -linewidth 1 -linecolor #FFFFFF -marker point -legend "Coil (Other structure)"
		}
		$plothandle replot
  
	}

	
	if { $guipercentage==1 } {
		set log [open _temp.dat w]
		set allresidue [[atomselect $currentmol "$selection and alpha"] get residue]
		if {$guiallframes==1} {
			set nf [molinfo $currentmol get numframes]
			for {set i 0} { $i<$nf } {incr i} {
				animate goto $i
				puts "$i"
				display update ui
				mol ssrecalc $currentmol
				set allss [[atomselect $currentmol "$selection and alpha"] get structure]
				puts $log "$allss"
			}
		}
		
		if {$guiallframes==0} {
			for {set i $firstframe} { $i <= $lastframe } {incr i} {
			animate goto $i
			display update ui
			mol ssrecalc $currentmol	
			set allss [[atomselect $currentmol "$selection and alpha"] get structure]
			puts $log "$allss"	
			}
		}	
		set length [expr [llength $allss]] 
		close $log
		set fp [open _temp.dat r]
		set file_data [read $fp]
		close $fp
		set data [split $file_data "\n"]
		########################### create map list###########################
		# get list of residues
		set allsel [atomselect $currentmol "$selection and alpha"]
		set residlist [lsort -unique -integer [ $allsel get resid ]]
		#  set two_list [llength [$allsel get resid]]
		# resid map for every atom  
		set allResid [$allsel get residue]
		# resname map for every atom
		set allResname [$allsel get resname]
		# create resid->resname map
		foreach resID $allResid resNAME $allResname {
			set mapResidResname($resID) $resNAME
			set mapResid($resID) $resID
		}
  
		
		
		######################################################################
		$win.sel.log.logtext insert end "Molecule: [molinfo $currentmol get name]\nSelection: $selection\nRes    ----> %T %E %B %H %G %I %C\n"
		puts $logdcd "Molecule: [molinfo $currentmol get name]\nSelection: $selection\nRes    ----> %T %E %B %H %G %I %C\n"
		for {set i 0} { $i<$length } {incr i} {
			set listrr {}
			puts "$i"
			display update ui
			foreach line $data {
				lappend listrr [lindex $line $i]
			}
			# here calculate precentage for each residue
			set all [expr ([llength $listrr]-1)]
			set numT [expr {wide((([expr {(([llength [lsearch -all $listrr T]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			set numE [expr {wide((([expr {(([llength [lsearch -all $listrr E]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			set numB [expr {wide((([expr {(([llength [lsearch -all $listrr B]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			set numH [expr {wide((([expr {(([llength [lsearch -all $listrr H]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			set numG [expr {wide((([expr {(([llength [lsearch -all $listrr G]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			set numI [expr {wide((([expr {(([llength [lsearch -all $listrr I]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			set numC [expr {wide((([expr {(([llength [lsearch -all $listrr C]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			foreach r $residlist {
			foreach {tmp resName} [split [array get mapResidResname $i] ] break
			foreach {tmp resID} [split [array get mapResid $i] ] break
			}
			$win.sel.log.logtext insert end "$resID $resName ---> $numT  $numE  $numB  $numH  $numG  $numI  $numC\n"
			puts $logdcd "$resID $resName ---> $numT  $numE  $numB  $numH  $numG  $numI  $numC\n"
		}   
	}
	
	if {$outputDcd != ""} {
		close $logdcd
	}
	
} 	

proc ::structure::secondary_pdb {} {
	variable win
	variable currentmol
	variable selection
	variable logtext
	variable gui3dchart
	variable guipiechart
	variable guipercentage
	variable sstype
	variable guiallframes
	variable firstframe
	variable lastframe
	variable outputPdb
	variable guieachres

	
	# set logpdb file
	if {$outputPdb == ""} {
		set logpdb "stdout"
	} else {
		set logpdb [open "$outputPdb" w]
	}
	
	
	if { $gui3dchart==1 } {
		
		set fulllist [set sss [[atomselect $currentmol "$selection and alpha"] get structure]]
		
		set all [llength $fulllist]
		# Draw Plot 
		destroy $win.three
		toplevel $win.three ;#Make the window
		wm title $win.three "3-D Chart"
		wm resizable $win.three 0 0
		################ menu ###################
		menu $win.three.menu -tearoff 0
		menu $win.three.menu.file -tearoff 0
		$win.three.menu add cascade -label "File   " -menu $win.three.menu.file -underline 0
		$win.three.menu.file add command -label "Export" \
			-command [namespace code {Exp_3D} ]
		$win.three configure -menu $win.three.menu
		# Put things in it
		pack [canvas $win.three.canvas -bg white -width 300 -height 290]
		set w $win.three.canvas
		set x0 30
		set x1 280
		set y3 220
		set y4 240
		$win.three.canvas create poly $x0 $y4 [expr $x0+25] $y3 $x1 $y3 [expr $x1-20] $y4 -fill gray75 -outline black
		$win.three.canvas create poly $x0 $y4 $x0 [expr $y4-180] [expr $x0+25] [expr $y3-180] [expr $x0+25] $y3 -fill gray75 -outline black
		# plot line back
		set y00 0
		while {$y00<181} {
			$win.three.canvas create line [expr $x0+25] [expr {$y3-$y00}] $x1 [expr {$y3-$y00}] -fill gray55
			incr y00 20
			}
		# plot line side
		set y01 0
		while {$y01<181} {
			$win.three.canvas create line $x0 [expr {$y4-$y01}] [expr $x0+25] [expr {$y3-$y01}]
			incr y01 20
		}
		$win.three.canvas create line $x1 $y3 $x1 [expr $y3-180]
		# text yscale
		$win.three.canvas create text [expr $x0-15] $y4 -text "0" -anchor w
		$win.three.canvas create text [expr $x0-20] [expr $y4-90] -text "50" -anchor w
		$win.three.canvas create text [expr $x0-20] [expr $y4-180] -text "100" -anchor w
		set listss { {T #469696} {E #FFFF64} {B #B4B400} {H #E182E1} {G #FF99FF} {I #ED1818} {C #FFFFFF} }
		set p1x 60; set p2x 75; set p2y 230
		$win.pdb.log.logtext insert end "Molecule: [molinfo $currentmol get name]\nSelection: $selection\nss type ----> percentage\n"
		puts $logpdb "Molecule: [molinfo $currentmol get name]\nSelection: $selection\nss type ----> percentage\n"
		foreach items $listss {
			foreach {ss color} $items break
			set num [expr {wide((([expr {(([llength [lsearch -all $fulllist $ss]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			set p1y [expr {230-($num*180/100)}]
			set p4x [expr $p2x+5]
			set p4y [expr $p1y-5]
			set p5y [expr $p2y-5]
			set p6x [expr $p1x+5]
			$win.three.canvas create rect $p1x $p1y $p2x $p2y -fill $color
			$win.three.canvas create poly $p2x $p2y $p2x $p1y $p4x $p4y $p4x $p5y -outline black -fill [[namespace current]::dim $color 0.8]
			$win.three.canvas create poly $p1x $p1y $p6x $p4y $p4x $p4y $p2x $p1y -outline black -fill [[namespace current]::dim $color 0.6]
			$win.three.canvas create text [expr $p1x+7] [expr $p2y+20] -text "$ss"	
			$win.three.canvas create text [expr $p1x+12] [expr $p1y-15] -text "$num"	
			incr p1x 30
			incr p2x 30
			$win.pdb.log.logtext insert end "$ss ----> $num%\n"
			puts $logpdb "$ss ----> $num%\n"
		}
	}

	if { $guipiechart==1 } {
		destroy $win.pie
		toplevel $win.pie ;#Make the window
		wm title $win.pie "Pie Chart"
		wm resizable $win.pie 0 0
		################ menu ###################
		menu $win.pie.menu -tearoff 0
		menu $win.pie.menu.file -tearoff 0
		$win.pie.menu add cascade -label "File   " -menu $win.pie.menu.file -underline 0
		$win.pie.menu.file add command -label "Export" \
			-command [namespace code {Exp_Pie} ]
		$win.pie configure -menu $win.pie.menu
		pack [canvas $win.pie.canvas -bg white -width 250 -height 250]
		set w $win.pie.canvas
		set x 50
		set y 50
		set width 150
		set height 150

		set coords [list $x $y [expr {$x+$width}] [expr {$y+$height}]]
		set xm  [expr {$x+$width/2.}]
		set ym  [expr {$y+$height/2.}]
		set rad [expr {$width/2.+20}]
		set sum 0
		set start 270
		
		set fulllist [set sss [[atomselect $currentmol "$selection and alpha"] get structure]]
		# set
		set all [llength $fulllist]
		set listss { {T #469696} {E #FFFF64} {B #B4B400} {H #E182E1} {G #FF99FF} {I #ED1818} {C #FFFFFF} }
		set start 270
		$win.pdb.log.logtext insert end "Molecule: [molinfo $currentmol get name]\nSelection: $selection\nss type ----> percentage\n"
		puts $logpdb "Molecule: [molinfo $currentmol get name]\nSelection: $selection\nss type ----> percentage\n"
		foreach items $listss {
			foreach {ss color} $items break
			set num [expr {wide((([expr {(([llength [lsearch -all $fulllist $ss]])/($all+0.0))*100}])*10**2) + 0.5) / double(10**2)}]
			if { $num > 0 } {
			    set extent [expr {$num*360./100}]
				$w create arc $coords -start $start -extent $extent -fill $color
				set angle [expr {($start-90+$extent/2)/180.*acos(-1)}]
				set tx [expr $xm-$rad*sin($angle)]
				set ty [expr $ym-$rad*cos($angle)]
				$w create text $tx $ty -text $ss:$num  -tag txt
				set start [expr $start+$extent]
			}
		$win.pdb.log.logtext insert end "$ss ----> $num%\n"	
		puts $logpdb "$ss ----> $num%\n"
		}
		$w raise txt
	}

	
	if { $guieachres==1 } {
#		$win.pdb.log.logtext delete 1.0 end
		set sel [[atomselect $currentmol "$selection and alpha"] get resid]
		# loop
		$win.pdb.log.logtext insert end "resid  resname  structure type\n"
		puts $logpdb "resid  resname  structure type\n"
		foreach rr $sel {
			set getresid [[atomselect $currentmol "protein and resid $rr and alpha"] get resid]
			set getresname [[atomselect $currentmol "protein and resid $rr and alpha"] get resname]
			set getstructure [[atomselect $currentmol "protein and resid $rr and alpha"] get structure]
			$win.pdb.log.logtext insert end "$getresid  $getresname  $getstructure\n"
			puts $logpdb "$getresid  $getresname  $getstructure\n"
		}	
	
	}
	if {$outputPdb != ""} {
		close $logpdb
	}	
	
}


proc ::structure::dim {color factor} {
  foreach i {r g b} n [winfo rgb . $color] d [winfo rgb . white] {
     set $i [expr int(255.*$n/$d*$factor)]
  }
  format #%02x%02x%02x $r $g $b
}


proc ::structure::SaveLog {} {
	variable save
	variable win
	
	set typeFile {
		{"Data Files" ".dat .txt"}
		{"All files" ".*"}
	}
	set file [tk_getSaveFile -filetypes $typeFile -defaultextension ".dat" -title "Inter File name to save data" -parent .structuregui]
	if {$file != ""} {
		set save $file
		set fd [open $file w]
		if { [winfo exists $win.pdb] } {
		set savealllog [$win.pdb.log.logtext get 1.0 end]
		}
		if { [winfo exists $win.sel] } {
		set savealllog [$win.sel.log.logtext get 1.0 end]
		}		
		puts $fd "$savealllog"
		close $fd
	}
	return
	
	winfo exist .frame
	
}


proc ::structure::OutputFilePdb {args} {
	variable win
	variable outputPdb

	set types {
		{{XVG Files} {.xvg}}
	}
	set o_filename [tk_getSaveFile -filetypes $types -defaultextension ".xvg"]
	set outputPdb $o_filename 
}

proc ::structure::OutputFileDcd {args} {
	variable win
	variable outputDcd

	set types {
		{{XVG Files} {.xvg}}
	}
	set o_filename [tk_getSaveFile -filetypes $types -defaultextension ".xvg"]
	set outputDcd $o_filename 
}


proc ::structure::ResetPlugin {} {
	variable win
	variable currentmol
	variable selection
	
	destroy $win.pdb
	destroy $win.sel
	destroy $win.pie
	destroy $win.three
	$win.mol.all.sel1 delete 0 end
	$win.mol.all.sel1 insert end "protein"
	set currentmol "Select Molecule"
	

}


proc ::structure::activate_frame {} {
	variable guiallframes
	variable win
	
	if { $guiallframes == 1 } {
		$win.sel.all.entryfirst insert end "First Frame"
		$win.sel.all.entrylast insert end "Last Frame"
		$win.sel.all.entryfirst configure -state disable
		$win.sel.all.entrylast configure -state disable
	} else {
		$win.sel.all.entryfirst configure -state normal
		$win.sel.all.entrylast configure -state normal
		$win.sel.all.entryfirst delete 0 end
		$win.sel.all.entrylast delete 0 end
	}
}


proc ::structure::Exp_3D {} {
	variable win

	set filename "3D Chart plot.ps"
	set filename [tk_getSaveFile -initialfile $filename -title "Secondary Structure Printing" -parent $win.three -filetypes [list {{Postscript Files} {.ps}} {{All files} {*} }] ]
	if {$filename != ""} {
		$win.three.canvas postscript -file $filename
	}
	return
}


proc ::structure::Exp_Pie {} {
	variable win

	set filename "Pie Chart plot.ps"
	set filename [tk_getSaveFile -initialfile $filename -title "Secondary Structure Printing" -parent $win.pie -filetypes [list {{Postscript Files} {.ps}} {{All files} {*} }] ]
	if {$filename != ""} {
		$win.pie.canvas postscript -file $filename
	}
	return
}



proc structure_tk_cb {} {
	::structure::structure_gui 
	return $::structure::win
}
	

