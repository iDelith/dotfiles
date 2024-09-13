vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Moving around
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move screen down centralized" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move screen up centralized" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>ss", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- resize panels
keymap.set("n", "<C-S-Left>", "5<C-w><", { desc = "Resize panel (-)" })
keymap.set("n", "<C-S-Right>", "5<C-w>>", { desc = "Resize panel (+)" })
keymap.set("n", "<C-S-Up>", "5<C-w>-", { desc = "Resize panel (up)" })
keymap.set("n", "<C-S-Down>", "5<C-w>+", { desc = "Resize panel (down)" })

-- move between buffers
keymap.set("n", "<tab>", ":tabnext<CR>", { desc = "Move to next buffer" })
keymap.set("n", "<S-tab>", ":tabprevious<CR>", { desc = "Move to previous buffer" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
