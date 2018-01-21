-- Inofficial Zcash Extension for MoneyMoney
-- Fetches Zcash quantity for addresses via ZCHAIN explorer.zcha.in API
-- Fetches Zcash price in EUR via cryptocompare.com API
-- Returns cryptoassets as securities
--
-- Username: Zcash Adresses comma seperated
-- Password: [Whatever]

-- MIT License

-- Copyright (c) 2018 crietzschel

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 1.0,
  description = "Include your Zcashs as cryptoportfolio in MoneyMoney by providing Zcash addresses as usernme (comma seperated) and a random Password",
  services= { "Zcash" }
}

local ZcashAddress
local connection = Connection()
local currency = "EUR"

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Zcash"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  ZcashAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Zcash",
    accountNumber = "Zcash",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestZcashPrice()

  for address in string.gmatch(ZcashAddress, '([^,]+)') do
    ZcashQuantity = requestZcashQuantityForZcashAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = ZcashQuantity,
      price = prices,
    }
  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestZcashPrice()
  response = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(response)

  return json:dictionary()['EUR']
end

function requestZcashQuantityForZcashAddress(ZcashAddress)
  response = connection:request("GET", ZcashRequestUrl(ZcashAddress), {})
  json = JSON(response)

  return json:dictionary()['balance']
end


-- Helper Functions
function cryptocompareRequestUrl()
  return "https://min-api.cryptocompare.com/data/price?fsym=ZEC&tsyms=EUR"
end

function ZcashRequestUrl(ZcashAddress)
  return "https://api.zcha.in/v2/mainnet/accounts/" .. ZcashAddress .. ""
end

-- SIGNATURE: MCwCFBGbUkL4jViKiRdvtPw1S11bCqo6AhQpVlCrTjM4mwyyGBO8paxrf9g8Ug==
