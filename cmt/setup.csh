# echo "setup xAODJetReclustering xAODJetReclustering-00-00-00 in /data/atlas/atlasdata3/burr/Multijets/trunk/Reclustering"

if ( $?CMTROOT == 0 ) then
  setenv CMTROOT /cvmfs/atlas.cern.ch/repo/sw/software/AthAnalysisBase/x86_64-slc6-gcc49-opt/2.4.6/CMT/v1r25p20140131
endif
source ${CMTROOT}/mgr/setup.csh
set cmtxAODJetReclusteringtempfile=`${CMTROOT}/${CMTBIN}/cmt.exe -quiet build temporary_name`
if $status != 0 then
  set cmtxAODJetReclusteringtempfile=/tmp/cmt.$$
endif
${CMTROOT}/${CMTBIN}/cmt.exe setup -csh -pack=xAODJetReclustering -version=xAODJetReclustering-00-00-00 -path=/data/atlas/atlasdata3/burr/Multijets/trunk/Reclustering  -no_cleanup $* >${cmtxAODJetReclusteringtempfile}
if ( $status != 0 ) then
  echo "${CMTROOT}/${CMTBIN}/cmt.exe setup -csh -pack=xAODJetReclustering -version=xAODJetReclustering-00-00-00 -path=/data/atlas/atlasdata3/burr/Multijets/trunk/Reclustering  -no_cleanup $* >${cmtxAODJetReclusteringtempfile}"
  set cmtsetupstatus=2
  /bin/rm -f ${cmtxAODJetReclusteringtempfile}
  unset cmtxAODJetReclusteringtempfile
  exit $cmtsetupstatus
endif
set cmtsetupstatus=0
source ${cmtxAODJetReclusteringtempfile}
if ( $status != 0 ) then
  set cmtsetupstatus=2
endif
/bin/rm -f ${cmtxAODJetReclusteringtempfile}
unset cmtxAODJetReclusteringtempfile
exit $cmtsetupstatus

