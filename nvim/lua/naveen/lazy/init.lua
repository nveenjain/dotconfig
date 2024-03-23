return {
    {
        'nvim-lua/plenary.nvim',
        name = 'plenary',
    },
    'ThePrimeagen/harpoon',
    {
      'declancm/cinnamon.nvim',
      config = function() require('cinnamon').setup() end
    },
}

