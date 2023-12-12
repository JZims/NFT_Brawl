import { useState } from 'react'
import './App.css'
import ConnectButton from './components/ConnectButton'
import { useAccount } from 'wagmi'




function App() {
 
  const {address, isConnecting, isDisconnected} = useAccount()
  const [count, setCount] = useState(0)
  
  const statusBar = () => {

    if(isConnecting){
      return <div>Connecting...</div>
    }
    else if (isDisconnected) {
      return <div>Disconnected</div>
    }
    return <div>Address: {address}</div>
  }

  return (
    <>
      
      <h1 className="text-xl">NFT Brawl</h1>
        <div className="">
          <label htmlFor="counter"> count is {count} </label>
          
          <button className="border-2" id="counter" onClick={() => setCount((count) => count + 1)}>
            Up
          </button>
          
          <button className="border-2" id="counter" onClick={() => setCount((count) => count - 1)}>
            Down
          </button>
        </div>
         <br/>
         <ConnectButton/>
         <br/>
         {statusBar()}
    </>

  
  )
}

export default App
