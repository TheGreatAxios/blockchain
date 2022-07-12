/// Signatures used to sign Ethereum transactions and messages.
class MsgSignature {
  final BigInt r;
  final BigInt s;
  final int v;

  MsgSignature(this.r, this.s, this.v);
}