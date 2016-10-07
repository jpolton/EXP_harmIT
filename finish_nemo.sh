#!/bin/bash

mv ocean.output ocean.output_$RUNNAME

#===============================================================
# RECONSTRUCTION
#===============================================================
echo `date` : Reconstruction
mv $WDIR/AMM60_* $OUTPUTDIR/
mv $WDIR/m* $OUTPUTDIR/

#qsub -V $JOBDIR/run_iodef_reconst.pbs
export EXEC=/work/n01/n01/kariho40/NOCSCOMBINE_1/nocscombine4
if `ls $OUTPUTDIR/mesh_zgr_0015.nc`; then
  fic=`ls $OUTPUTDIR/mesh_zgr_0015.nc |sed "s/_0015.nc//"`
  echo $fic
  for FILENAME in $fic; do
    $EXEC -f $FILENAME* -o $OUTPUTDIR/$FILENAME.nc
  done
fi

#qsub $JOBDIR/run_iodef_reconst.pbs
fic=`echo $OUTPUTDIR/AMM60_*restart_0015.nc `
date=`basename $fic | cut -d '_' -f 2 | sed -e 's/\*//'`
echo $date
echo dir  = $RESTARTDIR/$date
mkdir -p $RESTARTDIR/$date
for cnt in {0..1999}; do
  ind=`printf "%4.4d" $cnt`
  mv $OUTPUTDIR/AMM60_${date}_restart_${ind}.nc $RESTARTDIR/$date/restart_${ind}.nc
done
mkdir -p $LOGDIR/$date
mv $WDIR/ocean.output* $LOGDIR/$date/
mv $WDIR/output*init* $LOGDIR/$date/
mv $WDIR/output*abort* $LOGDIR/$date/
mv $WDIR/solver.stat $LOGDIR/$date/
mv $WDIR/stdouterr* $LOGDIR/$date/
mv $WDIR/namelist* $LOGDIR/$date/
mv $WDIR/layout.dat $LOGDIR/$date/

echo $nrestart $nn_it000 $nrestart
delta=`expr $nitend - $nn_it000 + 1`
echo $delta
nn_it000=`expr $nitend + 1`
nitend=`expr $nitend + $delta`
nrestart=`expr $nrestart + 1`
echo $date
grep 'date ndastp' $LOGDIR/$date/ocean.output*
#ndastp=`grep 'date ndastp' $LOGDIR/$date/ocean.output* | head -1 |sed s/[a-z]//g | sed "s/ //g"`
ndastp=`grep 'date' $LOGDIR/$date/ocean.output* | tail -1 |sed s/[a-z]//g | sed "s/ //g"`
echo **************************************
echo nrestart = $nrestart
echo nn_it000 = $nn_it000
echo nitend   = $nitend 
echo ndastp   = $ndastp
echo **************************************

echo $nrestart $nn_it000 $nitend $ndastp >> $JOBDIR/run_counter.txt
                   

exit
