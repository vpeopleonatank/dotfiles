fg() {
  git add .
  git commit -m "update"
  git push
}

get_compile_command() {
  mkdir build; cd build;
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..
  cd ..
  ln -s $(pwd)/build/compile_commands.json $(pwd)/compile_commands.json
}


show-process() {
ps -eo size,pid,user,command --sort -size | \
  awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' |\
  cut -d "" -f2 | cut -d "-" -f1
}

sync_jupyter() {
  fname="$PWD"/"$1".ipynb
  jupytext --sync $fname
  ipython $fname
}

source_openvino() {
  cd /opt/intel/openvino_2021/inference_engine 
  source /opt/intel/openvino_2021/bin/setupvars.sh
  cd -
}
