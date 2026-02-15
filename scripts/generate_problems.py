#!/usr/bin/env python3
"""
算数問題セット生成スクリプト

各オペランドの範囲を個別に指定して、ランダムな問題セットを生成します。
生成された問題セットはJSONファイルとして保存され、再利用可能です。

使用例:
  # 1桁+1桁の足し算
  python3 generate_problems.py \\
    --operation addition \\
    --first-min 1 --first-max 9 \\
    --second-min 1 --second-max 9 \\
    --count 100 \\
    --output problems/addition/1digit-plus-1digit.json

  # 九九（1桁×1桁）
  python3 generate_problems.py \\
    --operation multiplication \\
    --first-min 1 --first-max 9 \\
    --second-min 1 --second-max 9 \\
    --count 81 \\
    --output problems/multiplication/kuku-all.json
"""

import argparse
import json
import random
import sys
from datetime import datetime
from pathlib import Path


class ProblemGenerator:
    """問題生成クラス"""
    
    OPERATIONS = {
        'addition': {
            'symbol': '+',
            'operand1_name': 'augend',      # 被加数
            'operand2_name': 'addend',      # 加数
        },
        'subtraction': {
            'symbol': '-',
            'operand1_name': 'minuend',     # 被減数
            'operand2_name': 'subtrahend',  # 減数
        },
        'multiplication': {
            'symbol': '×',
            'operand1_name': 'multiplicand',  # 被乗数
            'operand2_name': 'multiplier',    # 乗数
        },
        'division': {
            'symbol': '÷',
            'operand1_name': 'dividend_factor',  # 商の範囲
            'operand2_name': 'divisor',          # 除数
        },
    }
    
    def __init__(self, operation, first_range, second_range, count, seed=None, description=None):
        """
        Args:
            operation: 演算種別 ('addition', 'subtraction', 'multiplication', 'division')
            first_range: 第1オペランドの範囲 {'min': int, 'max': int}
            second_range: 第2オペランドの範囲 {'min': int, 'max': int}
            count: 生成する問題数
            seed: 乱数シード（再現性のため）
            description: 問題セットの説明
        """
        if operation not in self.OPERATIONS:
            raise ValueError(f"不明な演算: {operation}")
        
        self.operation = operation
        self.first_range = first_range
        self.second_range = second_range
        self.count = count
        self.seed = seed or random.randint(1, 1000000)
        self.description = description
        
        random.seed(self.seed)
    
    def generate(self):
        """問題セットを生成"""
        if self.operation == 'addition':
            return self._generate_addition()
        elif self.operation == 'subtraction':
            return self._generate_subtraction()
        elif self.operation == 'multiplication':
            return self._generate_multiplication()
        elif self.operation == 'division':
            return self._generate_division()
    
    def _generate_addition(self):
        """足し算問題生成"""
        problems = []
        for _ in range(self.count):
            a = random.randint(self.first_range['min'], self.first_range['max'])
            b = random.randint(self.second_range['min'], self.second_range['max'])
            problems.append({
                'a': a,
                'b': b,
                'answer': a + b
            })
        return problems
    
    def _generate_subtraction(self):
        """引き算問題生成"""
        problems = []
        for _ in range(self.count):
            a = random.randint(self.first_range['min'], self.first_range['max'])
            b = random.randint(self.second_range['min'], self.second_range['max'])
            
            # a >= b を保証（負の答えを避ける）
            if a < b:
                a, b = b, a
            
            problems.append({
                'a': a,
                'b': b,
                'answer': a - b
            })
        return problems
    
    def _generate_multiplication(self):
        """掛け算問題生成"""
        problems = []
        for _ in range(self.count):
            a = random.randint(self.first_range['min'], self.first_range['max'])
            b = random.randint(self.second_range['min'], self.second_range['max'])
            problems.append({
                'a': a,
                'b': b,
                'answer': a * b
            })
        return problems
    
    def _generate_division(self):
        """割り算問題生成（割り切れる問題のみ）"""
        problems = []
        for _ in range(self.count):
            # quotient（商）を生成
            quotient = random.randint(self.first_range['min'], self.first_range['max'])
            # divisor（除数）を生成
            divisor = random.randint(self.second_range['min'], self.second_range['max'])
            # dividend（被除数）= quotient × divisor
            dividend = quotient * divisor
            
            problems.append({
                'a': dividend,
                'b': divisor,
                'answer': quotient
            })
        return problems
    
    def to_json(self):
        """JSON形式で出力"""
        op_info = self.OPERATIONS[self.operation]
        
        metadata = {
            'operation': self.operation,
            'symbol': op_info['symbol'],
            'created_at': datetime.now().isoformat(),
            'seed': self.seed,
            'count': self.count,
            'ranges': {
                op_info['operand1_name']: self.first_range,
                op_info['operand2_name']: self.second_range,
            }
        }
        
        if self.description:
            metadata['description'] = self.description
        
        return {
            'metadata': metadata,
            'problems': self.generate()
        }


def main():
    parser = argparse.ArgumentParser(
        description='算数問題セット生成スクリプト',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
使用例:
  # 1桁+1桁の足し算
  %(prog)s --operation addition \\
    --first-min 1 --first-max 9 \\
    --second-min 1 --second-max 9 \\
    --count 100 \\
    --output problems/addition/1digit-plus-1digit.json

  # 九九の2の段
  %(prog)s --operation multiplication \\
    --first-min 1 --first-max 9 \\
    --second-min 2 --second-max 2 \\
    --count 9 \\
    --output problems/multiplication/kuku-2.json

  # 2桁÷1桁（割り切れる）
  %(prog)s --operation division \\
    --first-min 10 --first-max 20 \\
    --second-min 2 --second-max 5 \\
    --count 100 \\
    --output problems/division/2digit-div-1digit.json
        '''
    )
    
    parser.add_argument(
        '--operation',
        required=True,
        choices=['addition', 'subtraction', 'multiplication', 'division'],
        help='演算種別'
    )
    
    parser.add_argument(
        '--first-min',
        type=int,
        required=True,
        help='第1オペランドの最小値（加算:被加数, 減算:被減数, 乗算:被乗数, 除算:商の最小値）'
    )
    
    parser.add_argument(
        '--first-max',
        type=int,
        required=True,
        help='第1オペランドの最大値'
    )
    
    parser.add_argument(
        '--second-min',
        type=int,
        required=True,
        help='第2オペランドの最小値（加算:加数, 減算:減数, 乗算:乗数, 除算:除数）'
    )
    
    parser.add_argument(
        '--second-max',
        type=int,
        required=True,
        help='第2オペランドの最大値'
    )
    
    parser.add_argument(
        '--count',
        type=int,
        required=True,
        help='生成する問題数'
    )
    
    parser.add_argument(
        '--output',
        required=True,
        help='出力JSONファイルパス'
    )
    
    parser.add_argument(
        '--seed',
        type=int,
        help='乱数シード（再現性のため）'
    )
    
    parser.add_argument(
        '--description',
        help='問題セットの説明'
    )
    
    args = parser.parse_args()
    
    # 範囲の検証
    if args.first_min > args.first_max:
        print(f"エラー: first-min ({args.first_min}) > first-max ({args.first_max})", file=sys.stderr)
        sys.exit(1)
    
    if args.second_min > args.second_max:
        print(f"エラー: second-min ({args.second_min}) > second-max ({args.second_max})", file=sys.stderr)
        sys.exit(1)
    
    # 問題生成
    generator = ProblemGenerator(
        operation=args.operation,
        first_range={'min': args.first_min, 'max': args.first_max},
        second_range={'min': args.second_min, 'max': args.second_max},
        count=args.count,
        seed=args.seed,
        description=args.description
    )
    
    result = generator.to_json()
    
    # 出力ディレクトリ作成
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # JSON出力
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    print(f"✓ 問題セット生成完了: {args.output}")
    print(f"  演算: {result['metadata']['operation']} ({result['metadata']['symbol']})")
    print(f"  問題数: {result['metadata']['count']}")
    print(f"  シード: {result['metadata']['seed']}")
    print(f"  範囲:")
    for name, range_data in result['metadata']['ranges'].items():
        print(f"    {name}: {range_data['min']}-{range_data['max']}")


if __name__ == '__main__':
    main()