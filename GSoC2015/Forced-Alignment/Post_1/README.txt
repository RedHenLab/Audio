(1) Downloading Kaldi
(2) Installing Kaldi on Linux
(3) Set variables and execute run.sh 


(1) Downloading Kaldi
    -- Make sure that subversion (svn) is installed
    -- Type the following
       svn co https://svn.code.sf.net/p/kaldi/code/trunk kaldi-trunk
    -- In case, above command throws error, edit ~/.subversion/servers to make
       [global]
       http-proxy-host = proxy.iiit.ac.in  (line 144)
       http-proxy-port = 8080              (line 145)
 

(2) Installing Kaldi on Linux
    -- A folder named "kaldi-trunk" must have been created in the present directory
    -- cd kaldi-trunk/tools
    -- make -j <num_free_CPUs>    // use -j option for faster installation
    -- cd ../src
    -- ./configure
    -- make depend -j <num_free_CPUs>
    -- make -j <num_free_CPUs>
    -- Kaldi installation is complete. 
    -- Add .../kaldi-trunk/src/*bin, .../kaldi-trunk/tools/openfst-1.3.4/src/bin and 
       .../kaldi-trunk/tools/irstlm/bin to $PATH in ~/.bashrc file


