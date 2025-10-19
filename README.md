# kipu-bank

KipuBank es un contrato educativo que permite a los usuarios depositar y retirar ETH en una bóveda personal, con:
- Límite máximo por transacción (`withdrawLimit`, inmutable).
- Tope global de depósitos (`bankCap`, inmutable).
- Eventos en depósitos y retiros.
- Contadores de operaciones.

---

## 📌 Contrato desplegado (Sepolia)
- **Contract address:** `0x9abac65f17dbee791518b8859c25ea0aeccd22ee`  
- **Etherscan (verificado):** https://sepolia.etherscan.io/address/0x9abac65f17dbee791518b8859c25ea0aeccd22ee
- 0x9Abac65F17DbEe791518b8859c25Ea0aeccd22eE
- https://sepolia.etherscan.io/verifyContract-solc?a=0x9abac65f17dbee791518b8859c25ea0aeccd22ee&c=v0.8.26%2bcommit.8a97fa7a&lictype=3

---

## Estructura del repo

---

## Cómo compilar y desplegar (Remix + MetaMask)
1. Abrir [Remix](https://remix.ethereum.org).  
2. Crear archivo `contracts/KipuBank.sol` y pegar el código.  
3. En **Solidity Compiler** seleccionar `0.8.26`, compilar.  
4. En **Deploy & Run Transactions**:
   - Environment: `Injected Provider - MetaMask`
   - Network: **Sepolia Test Network**
   - Constructor args (ejemplo): `1e18, 10e18` → (1 ETH, 10 ETH en wei)
   - Click **Deploy** y confirma en MetaMask.
5. Copiar dirección del contrato desplegado y verificar en Etherscan (si no lo haces desde Remix, usar la opción *Verify and Publish* en Etherscan con:
   - Compiler: `v0.8.26+commit.8a97fa7a`
   - Optimization: Yes (si usaste optimizador) o No
   - License: `MIT`
   - Pegar código fuente y constructor args ABI-encoded.

---

## Cómo interactuar (ejemplos)
- **Deposit (Remix):** Llamar `deposit()` y en `Value` poner la cantidad (ej. 0.1 ETH).  
- **Withdraw (Remix):** Llamar `withdraw(amountInWei)` desde la cuenta que tiene balance.  
- **Read (Etherscan):** En la pestaña `Read Contract` puedes llamar `getBalance(address)` y ver `getDepositCount`, `getWithdrawalCount`.

---

## Seguridad y buenas prácticas aplicadas
- Uso de **custom errors** para menor gas y claridad.  
- Aplicación del patrón **checks-effects-interactions**.  
- Transferencia segura usando `call` y control de `success`.  
- Variables inmutables para límites (`withdrawLimit`, `bankCap`).

