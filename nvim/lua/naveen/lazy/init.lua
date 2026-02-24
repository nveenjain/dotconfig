return {
    {
        'nvim-lua/plenary.nvim',
        name = 'plenary',
    },
    'ThePrimeagen/harpoon',
    {
      'declancm/cinnamon.nvim',
      event = "VeryLazy",
      config = function() require('cinnamon').setup() end
    },
}

