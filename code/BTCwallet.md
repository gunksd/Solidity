# Simple Bitcoin Wallet

这是一个简单的比特币钱包示例，使用Python编写，提供以下功能：

1. 创建比特币钱包（生成私钥、公钥和比特币地址）
2. 保存和加载钱包
3. 查询比特币地址余额
4. 发送比特币交易

## 环境要求

在运行此代码之前，请确保已经安装了以下库：

```bash
pip install bitcoin requests
```
## 文件说明
* wallet.py：主程序文件，包含钱包创建、加载、余额查询和交易发送功能。
* wallet.json：钱包文件，保存生成的私钥、公钥和比特币地址。
## 使用说明
### 1. 创建或加载钱包
当你第一次运行程序时，如果没有找到wallet.json文件，将会自动创建一个新的比特币钱包，并将私钥、公钥和比特币地址保存在文件中。
```
python wallet.py
```
### 2. 加载现有钱包
如果已经有了`wallet.json`文件，可以直接加载现有钱包信息：
```
python wallet.py
```
### 3. 查询比特币地址余额
程序将会查询你的比特币地址的余额，并显示在控制台上：
```
python wallet.py
```
### 4. 发送比特币交易
你可以使用send_transaction函数发送比特币交易。请确保提供正确的未花费交易输出（UTXO）和接收地址：
```
# Replace with your actual parameters
tx_hex = send_transaction(private_key, "recipient_address_here", amount_in_btc)
print(f"Transaction hex: {tx_hex}")
```
请注意，发送交易需要实际的未花费交易输出（UTXO）和接收地址，这些参数需要根据实际情况修改。
## 注意事项
* 私钥安全性：私钥是控制你比特币的关键，请妥善保管，避免泄露。
* 实际交易：发送交易示例中需要提供实际的未花费交易输出（UTXO）和接收地址。















