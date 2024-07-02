import os
import json
import bitcoin
import requests
from bitcoin import SelectParams
from bitcoin.wallet import CBitcoinSecret, P2PKHBitcoinAddress
from bitcoin.core import lx, b2x, b2lx
from bitcoin.core.script import CScript, OP_CHECKSIG
from bitcoin.wallet import CBitcoinSecret
from bitcoin.core import b2x, lx, COIN, COutPoint, CTxIn, CTxOut, CMutableTxOut, CMutableTxIn, CMutableTransaction

def create_btc_wallet():
    # 生成私钥
    private_key = bitcoin.random_key()
    print(f"Private Key: {private_key}")

    # 生成公钥
    public_key = bitcoin.privtopub(private_key)
    print(f"Public Key: {public_key}")

    # 生成比特币地址
    btc_address = bitcoin.pubtoaddr(public_key)
    print(f"Bitcoin Address: {btc_address}")

    # 保存到文件
    wallet = {
        "private_key": private_key,
        "public_key": public_key,
        "btc_address": btc_address
    }

    with open("wallet.json", "w") as f:
        json.dump(wallet, f)

    return private_key, public_key, btc_address

def load_btc_wallet():
    if os.path.exists("wallet.json"):
        with open("wallet.json", "r") as f:
            wallet = json.load(f)
            private_key = wallet["private_key"]
            public_key = wallet["public_key"]
            btc_address = wallet["btc_address"]
            print(f"Wallet loaded: {btc_address}")
            return private_key, public_key, btc_address
    else:
        print("No wallet found, creating a new one...")
        return create_btc_wallet()

def get_balance(address):
    url = f"https://blockchain.info/q/addressbalance/{address}"
    response = requests.get(url)
    balance = int(response.text) / 1e8  # Convert satoshi to BTC
    print(f"Balance for {address}: {balance} BTC")
    return balance

def send_transaction(private_key, to_address, amount):
    SelectParams('mainnet')
    
    my_key = CBitcoinSecret.from_secret_bytes(bytes.fromhex(private_key))
    my_address = P2PKHBitcoinAddress.from_pubkey(my_key.pub)
    
    txid = "your_txid_here"  # You need to provide an unspent transaction output (UTXO)
    vout = 0  # Output index
    
    txin = CMutableTxIn(COutPoint(lx(txid), vout))
    
    txout = CMutableTxOut(int(amount * COIN), CBitcoinAddress(to_address).to_scriptPubKey())
    
    tx = CMutableTransaction([txin], [txout])
    
    sighash = SignatureHash(CScript([OP_CHECKSIG]), tx, 0, SIGHASH_ALL)
    sig = my_key.sign(sighash) + bytes([SIGHASH_ALL])
    
    txin.scriptSig = CScript([sig, my_key.pub])
    
    serialized_tx = b2x(tx.serialize())
    print(f"Raw transaction: {serialized_tx}")
    
    return serialized_tx

if __name__ == "__main__":
    private_key, public_key, btc_address = load_btc_wallet()
    balance = get_balance(btc_address)
    
    # 发送交易示例（需要实际的UTXO和接收地址）
    # tx_hex = send_transaction(private_key, "recipient_address_here", amount_in_btc)
    # print(f"Transaction hex: {tx_hex}")
