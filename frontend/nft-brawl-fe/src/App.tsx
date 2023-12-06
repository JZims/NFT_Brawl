import { useState } from 'react'
import './App.css'
import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/react'

import { WagmiConfig } from 'wagmi'
import { arbitrum, mainnet } from 'viem/chains'

const projectId = 'YOUR_PROJECT_ID'


const metadata = {
  name: 'Web3Modal',
  description: 'Web3Modal Example',
  url: 'https://web3modal.com',
  icons: ['https://avatars.githubusercontent.com/u/37784886']
}

const chains = [mainnet, arbitrum]
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata })


function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <h1 className="text-xl">NFT Brawl</h1>
      <div className="">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
      </div>
     
    </>
  )
}

export default App
