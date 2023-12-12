import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { WagmiConfig } from 'wagmi'
import { arbitrum, mainnet } from 'viem/chains'
import { defaultWagmiConfig, createWeb3Modal } from '@web3modal/wagmi/react'

const metadata = {
  name: 'Web3Modal',
  description: 'Web3Modal Example',
  url: 'https://web3modal.com',
  icons: ['https://avatars.githubusercontent.com/u/37784886']
}

const projectId = (import.meta.env.VITE_PROJECT_ID)
const chains = [mainnet, arbitrum]
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata })

createWeb3Modal({ wagmiConfig, projectId, chains })

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <WagmiConfig config={(wagmiConfig)}>
      <App />
    </WagmiConfig>
  </React.StrictMode>,
)
