return {
    {
        'kevinhwang91/nvim-bqf',
        dependencies = {
            {
                'junegunn/fzf',
                run = function()
                    vim.fn['fzf#install']()
                end
            }
        },
        ft = 'qf',
        opts = {
            auto_enable = true,
            auto_resize_height = true,
        },
    }
}
