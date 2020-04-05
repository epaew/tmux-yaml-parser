# Tmux ERB Parser
[![Gem Version](https://badge.fury.io/rb/tmux-erb-parser.svg)](https://badge.fury.io/rb/tmux-erb-parser)
[![Build Status](https://github.com/epaew/tmux-erb-parser/workflows/Run%20TestUnit/badge.svg)](https://github.com/epaew/tmux-erb-parser/actions?query=workflow%3A%22Run+TestUnit%22+branch%3A%22master%22)
[![Maintainability](https://api.codeclimate.com/v1/badges/a4c67b3c8ba8e555d98f/maintainability)](https://codeclimate.com/github/epaew/tmux-erb-parser/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a4c67b3c8ba8e555d98f/test_coverage)](https://codeclimate.com/github/epaew/tmux-erb-parser/test_coverage)

A Tmux plugin for loading tmux.conf written in Ruby (eRuby) notation.  
[What's eRuby?](https://ruby-doc.org/stdlib/libdoc/erb/rdoc/ERB.html)

## Requirements
* bash
    * For script execution.
    * You can use whatever you like as the default shell.
* git
* ruby:
    * 2.5 or higher is required.
* tmux

## How to use
1. Create your `tmux.conf.erb` and place it.
    * By default, tmux-erb-parser loads all `*.erb` files in `~/.config/tmux/`
    * Or you can change the load path. (Please see below.)
    * Sample configuration file:
        * [sample.tmux.conf.erb](test/fixtures/sample.tmux.conf.erb)
        * [sample.tmux.conf.yaml](test/fixtures/sample.tmux.conf.yaml)
2. Install tmux-erb-parser and run tmux!

### Install with tpm (Tmux Plugin Manager)
* [Install tpm](https://github.com/tmux-plugins/tpm#installation)
* Put this at the bottom of `~/.tmux.conf` (`$XDG_CONFIG_HOME/tmux/tmux.conf` works too, **but not your tmux.conf.erb!**):
    ```tmux
    setenv -g TMUX_CONF_EXT_PATH "path/to/tmux.conf.erb" # set your tmux.conf.erb's path
    # Note: You can specify multiple files using glob expressions. This is parsed by bash.

    set -g @plugin 'epaew/tmux-erb-parser'
    set -g @plugin 'tmux-plugins/tpm'
    # and list other plugins you want to install

    # Initialize Tmux plugin manager (keep this line at the very bottom of tmux.conf)
    run -b '~/.tmux/plugins/tpm/tpm'
    ```

* Run tmux and press `Prefix + I` to install plugins!

### Install and configure with git/rubygems
* Install:
    * with git:
        ```bash
        git clone https://github.com/epaew/tmux-erb-parser ~/.tmux/plugins/tmux-erb-parser
        ```
    * from rubygems:
        ```bash
        gem install tmux-erb-parser
        ```

* Configure:
    * Put this in `~/.tmux.conf` (`$XDG_CONFIG_HOME/tmux/tmux.conf` works too, **but not your tmux.conf.erb!**):
        ```tmux
        run -b 'path/to/bin/tmux-erb-parser --inline path/to/tmux.conf.erb'
        ```

## License
[MIT](LICENSE)
