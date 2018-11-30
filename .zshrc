# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=/home/talley/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="sobole"
SOBOLE_THEME_MODE=dark

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="false"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="false"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"
HIST_IGNORE_SPACE="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git python extract )

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

streaming() {
     INRES="1920x1080" # input resolution
     OUTRES="1920x1080" # output resolution
     FPS="30" # target FPS
     GOP="60" # i-frame interval, should be double of FPS,
     GOPMIN="30" # min i-frame interval, should be equal to fps,
     THREADS="2" # max 6
     CBR="2750k" # constant bitrate (should be between 1000k - 3000k)
     MBR="3500k"
     QUALITY="faster"  # one of the many FFMPEG preset
     AUDIO_RATE="44100"
     ABR="160k"
     INGEST="nyc-ingest" # place the closest ingest server
     INSOURCE="$1" # use the terminal comand streaming infilehere
     ST=$4 # subtitle track
     SF=$3 # subtitle file
     AT=$2 # audiotrack
     if [[ "$4" -eq "twitch" ]] || [[ "$3" -eq "twitch" ]] || [[ "$2" -eq "twitch" ]]
     then
          STREAM_KEY=`cat ~/.streamkeys/twitchkey`  # use the terminal command streaming infilehere
	  SERVER="rtmp://live-iad.twitch.tv/app/$STREAM_KEY"
     else
          STREAM_KEY=`cat ~/.streamkeys/angelthumpkey` # use the terminal command streaming infilehere
	  SERVER="rtmp://$INGEST.angelthump.com:1935/live/$STREAM_KEY"
     fi
     if [[ "$ST" -ne "twitch" ]]
     then
	extension=".${INSOURCE##*.}"
	ftmp=`mktemp -u -p . --suffix $extension`
	ln "$INSOURCE" "$ftmp"
	echo $ftmp
        ffmpeg -re -i "$INSOURCE" -c:v libx264 -pix_fmt yuv420p -preset $QUALITY -b:v $CBR -maxrate $MBR \
            -tune animation -vf subtitles="$ftmp":si=$ST -map 0:0 -map 0:a:$AT \
            -x264-params keyint=$GOP -c:a aac -strict 2 -ar $AUDIO_RATE -b:a $ABR -ac 2 -bufsize 7000k \
            -f flv $SERVER
	rm -rf $ftmp
     elif [[ "$SF" -ne "twitch" ]]
     then
	     echo "File"
        ffmpeg -re -i "$INSOURCE" -c:v libx264 -pix_fmt yuv420p -preset $QUALITY -b:v $CBR -maxrate $MBR \
            -tune animation -vf subtitles="$SF":si=0 -map 0:0  -map 0:a:$AT \
            -x264-params keyint=$GOP -c:a aac -strict 2 -ar $AUDIO_RATE -b:a $ABR -ac 2 -bufsize 7000k \
            -f flv $SERVER
     else
        ffmpeg -re -i "$INSOURCE" -c:v libx264 -pix_fmt yuv420p -preset $QUALITY -b:v $CBR -maxrate $MBR \
            -x264-params keyint=$GOP -c:a aac -strict 2 -ar $AUDIO_RATE -b:a $ABR -ac 2 -bufsize 7000k \
            -f flv $SERVER
     fi
}
streamfolder() {
	for i in *
	do
		streaming $i $1 $2 $3 $4
	done
}
