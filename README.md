# vim-insert-timestamp

vim-insert-timestamp is a vim plugin to easily input datetime timestamps (with
previewing) based on natural language processing.

## Example

**Here is an example of vim-insert-timestamp in action!**

![usage](https://i.imgur.com/ar2N9Xj.gif)

## Installing
vim-insert-timestamp uses python3 and
[parsedatetime](https://github.com/bear/parsedatetime), so be sure to have them
installed:

    pip3 install parsedatetime

Then, install vim-insert-timestamp using either
[pathogen](https://github.com/tpope/vim-pathogen) or
[vundle](https://github.com/VundleVim/Vundle.vim). For example, for vundle, add
the following lines to your ``~/.vimrc``:

    Plugin 'alkim0/vim-insert-timestamp'

Then enable the plugin with the following line in your ``~/.vimrc``:

    call InsertTimestampEnable()

I like to only enable it for vimwiki files, so I use:

    autocmd FileType vimwiki call InsertTimestampEnable()

The ``g:insert_timestamp_start_key`` variable controls which key combination
you want to use to start the timestamp insertion. By default, this is
``<C-l>``.

The ``g:insert_timestamp_complete_key`` variable controls which key combination
you want to use to complete to the current previewd timestamp. By default, this
is ``<Tab>``.

## Usage
After you have enabled vim-insert-timestamp. Go into insert mode, and press
``<C-l>`` (or whatever you configured to). A preview window will pop up, and as
you type more details, the previewd timestamp will be refined. To complete to
the currently previewed timestamp, press ``<Tab>`` (or whatever you configured
it to). To get out of insert timestamp mode, either press ``<C-l>`` again or
``<Esc>``.

vim-insert-timestamp outputs the timestamp in a format similar to Emacs's
[org-mode](http://orgmode.org/). It can output both individual timestamps and
timestamp ranges.
