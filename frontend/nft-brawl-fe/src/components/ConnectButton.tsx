import { useWeb3Modal } from '@web3modal/wagmi/react'
import { ReactComponentElement } from 'react'

export default function ConnectButton(): ReactComponentElement {
  // 4. Use modal hook
  const { open } = useWeb3Modal()

  return (
    <>
      <button className="border-2" onClick={() => open()}>Open Connect Modal</button>
      <br/>
      <button className="border-2" onClick={() => open({ view: 'Networks' })}>Open Network Modal</button>
    </>
  )
}