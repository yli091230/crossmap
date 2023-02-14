#!/bin/bash

get_slurm_header()
{
  if [ $# -lt 9 ]; then 
         echo "#not enough arguments in ${FUNCNAME}."; 
       return 1; 
       fi
       
       partition=$1
       workdir=$2
       time=$3
       nodes=$4
       ntasks=$5
       mem=$6
       job_name=$7
       out_fn=$8
       err_fn=$9
       acct_info=${10}       
       
       cmd_header="#"'!'"/bin/bash"
       cmd_header="$cmd_header\n#SBATCH --partition=${partition}"
       cmd_header="$cmd_header\n#SBATCH --chdir=${workdir}"
       cmd_header="$cmd_header\n#SBATCH --time=${time}"
       cmd_header="$cmd_header\n#SBATCH --nodes=${nodes}"
       cmd_header="$cmd_header\n#SBATCH --ntasks=${ntasks}"
       cmd_header="$cmd_header\n#SBATCH --mem=${mem}"
       cmd_header="$cmd_header\n#SBATCH --job-name=${job_name}"
       cmd_header="$cmd_header\n#SBATCH --output=${out_fn}"
       cmd_header="$cmd_header\n#SBATCH --error=${err_fn}"
       cmd_header="$cmd_header\n#SBATCH --account=${acct_info}"
       cmd_header="$cmd_header\n#SBATCH --export=NONE"
       cmd_header="$cmd_header\n"
       
       echo $cmd_header
       return 0
}

submit_slurm_job()
{
  if [ $# -lt 1 ]; then 
    echo "No script to submit"; 
    return 1; 
  fi
  script_fn=$1
  
  # default settings
  partition="shared"
  nodes=1
  ntasks=1
  time="1:0:0"
  mem="4GB"

  if [ $# -ge 2 ]; then partition=$2; fi
  if [ $# -ge 3 ]; then nodes=$3; fi
  if [ $# -ge 4 ]; then ntasks=$4; fi
  if [ $# -ge 5 ]; then time=$5; fi
  if [ $# -ge 6 ]; then mem=$6; fi
  if [ $# -ge 7 ]; then account=$7; fi
  # slurm header
  script_dir="$(dirname "$script_fn")"
  job_name="$(basename "$script_fn")"
  slurm_job_fn="${script_fn}.slurm"
  cmd_header=$(get_slurm_header ${partition} ${script_dir} ${time} ${nodes} ${ntasks} ${mem} ${job_name} "${slurm_job_fn}.%%j.out" "${slurm_job_fn}.%%j.err" ${account})
  echo ${cmd_header}
  # slurm modules
#  cmd_modules="export PATH=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/tools/bowtie-1.2.2-linux-x86_64:$PATH"
  cmd_modules="module purge"
  cmd_modules="${cmd_modules}\nmodule load cpu/0.15.4  gcc/9.2.0 slurm"
  cmd_modules="$cmd_modules\nmodule load r/4.0.2-openblas"
  cmd_modules="$cmd_modules\nmodule list"
  cmd_modules="$cmd_modules\n"
  
  # target script
  #cmd_body="export PATH=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/tools/bowtie-1.2.2-linux-x86_64:$PATH"
  cmd_body="bash \"$script_fn\""
  cmd_body="$cmd_body\necho DONE"

  # save slurm job
  printf "$cmd_header\n" > $slurm_job_fn
  printf "$cmd_modules\n" >> $slurm_job_fn
  printf "$cmd_body\n" >> $slurm_job_fn

  # submit slurm job
  sbatch $slurm_job_fn
  
  return 0
}

