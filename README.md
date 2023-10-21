# VMD-SS: A graphical user interface plug-in to calculate the protein secondary structure in VMD program


# install plug-in

step 1: Create a new folder in $VMD/plugins/noarch/tcl with the name of ssplugin

step 2: Copy secondary-structure.tcl and pkgIndex.tcl files into ssplugin folder

step 3: Open the configuration file of VMD (.vmdrc for Unix platforms or vmd.rc for Windows platforms) in the directory of $VMD

step 4:  Copy the following lines of code at the end of the configuration file
  set $dir VMD/plugins/noarch/tcl/ssplugin
  source $dir/pkgIndex.tcl
  vmd_install_extension secondary_structure structure_tk_cb “Analysis/VMD-SS”

step 5: In the Main window, choose Extensions –> Analysis –> VMD-SS



# use VMD-SS immediately

Copy the secondary-structure.tcl to the VMD root directory
In the VMD Main window, choose Extensions –> TK Console and type:

source secondary-structure.tcl
structure_tk_cb
