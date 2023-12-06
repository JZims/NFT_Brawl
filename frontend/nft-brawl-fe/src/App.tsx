import { useState } from 'react'
import './App.css'
import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/react'
import ConnectButton from './components/ConnectButton'
import { WagmiConfig } from 'wagmi'
import { arbitrum, mainnet } from 'viem/chains'

const projectId = (import.meta.env.VITE_PROJECT_ID)

console.log(import.meta.env.MODE)
console.log(projectId)

const metadata = {
  name: 'Web3Modal',
  description: 'Web3Modal Example',
  url: 'https://web3modal.com',
  icons: ['https://avatars.githubusercontent.com/u/37784886']
}

const chains = [mainnet, arbitrum]
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata })

createWeb3Modal({ wagmiConfig, projectId, chains })

function App() {
  const [count, setCount] = useState(0)

  return (

   <WagmiConfig config={wagmiConfig} >

      <h1 className="text-xl">NFT Brawl</h1>
      <div className="">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
      </div>
      <ConnectButton> WalletConnect Lol </ConnectButton>
    </WagmiConfig> 
  )
}

export default App
