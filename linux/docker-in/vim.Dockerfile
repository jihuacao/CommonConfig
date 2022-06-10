# config vim
RUN \
echo "config vim" \
## download the Vundle
&& cp -r DockerContext/Vundle.vim ~/.vim/bundle/Vundle.vim \
## install the vim
&& apt -y install vim
&& echo "done"