return {
    {
      'declancm/cinnamon.nvim',
      event = "VeryLazy",
      config = function() require('cinnamon').setup() end
    },
}

