#!/usr/bin/env python3
"""
Test suite for documentation files.

Tests cover:
- Markdown syntax validation
- Link checking (internal links)
- Code block syntax validation
- Documentation completeness
- Consistency checks
"""

import re
import sys
from pathlib import Path
from typing import List, Dict, Set


class TestDocumentation:
    """Test suite for markdown documentation."""

    def __init__(self):
        self.repo_root = Path(__file__).parent.parent.parent
        self.errors = []
        self.warnings = []

    def get_markdown_files(self) -> List[Path]:
        """Get all markdown files in the repository."""
        return list(self.repo_root.glob("**/*.md"))

    def test_markdown_syntax(self):
        """Test basic markdown syntax."""
        print("Testing markdown syntax...")
        md_files = self.get_markdown_files()
        
        for filepath in md_files:
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Check for basic markdown issues
                lines = content.split('\n')
                
                # Check for unclosed code blocks
                in_code_block = False
                code_block_start_line = 0
                for i, line in enumerate(lines, 1):
                    if line.strip().startswith('```'):
                        if in_code_block:
                            in_code_block = False
                        else:
                            in_code_block = True
                            code_block_start_line = i
                
                if in_code_block:
                    self.errors.append(f"{filepath.name}: Unclosed code block starting at line {code_block_start_line}")
                else:
                    print(f"  ✓ {filepath.name}: Valid markdown syntax")
                
            except Exception as e:
                self.errors.append(f"{filepath.name}: Error reading file: {e}")

    def test_internal_links(self):
        """Test that internal links point to existing files."""
        print("\nTesting internal links...")
        md_files = self.get_markdown_files()
        
        for filepath in md_files:
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Find markdown links: [text](path)
                links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', content)
                
                for link_text, link_path in links:
                    # Skip external links
                    if link_path.startswith('http://') or link_path.startswith('https://'):
                        continue
                    
                    # Skip anchors only
                    if link_path.startswith('#'):
                        continue
                    
                    # Remove anchor from path
                    clean_path = link_path.split('#')[0]
                    
                    if not clean_path:
                        continue
                    
                    # Resolve relative path
                    target_path = (filepath.parent / clean_path).resolve()
                    
                    if not target_path.exists():
                        self.errors.append(f"{filepath.name}: Broken link to '{clean_path}'")
                
                print(f"  ✓ {filepath.name}: Internal links checked")
                
            except Exception as e:
                self.errors.append(f"{filepath.name}: Error checking links: {e}")

    def test_code_blocks(self):
        """Test that code blocks have language specifiers."""
        print("\nTesting code blocks...")
        md_files = self.get_markdown_files()
        
        for filepath in md_files:
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                lines = content.split('\n')
                
                for i, line in enumerate(lines, 1):
                    if line.strip().startswith('```'):
                        # Check if language is specified
                        code_fence = line.strip()
                        if code_fence == '```':
                            self.warnings.append(f"{filepath.name}:{i}: Code block without language specifier")
                
            except Exception as e:
                self.errors.append(f"{filepath.name}: Error checking code blocks: {e}")
        
        print("  ✓ Code block check complete")

    def test_documentation_completeness(self):
        """Test that key documentation sections exist."""
        print("\nTesting documentation completeness...")
        
        # Check for monitoring documentation
        monitoring_docs = [
            self.repo_root / "docs" / "monitoring-setup.md",
            self.repo_root / "kubernetes" / "infrastructure" / "monitoring" / "README.md",
            self.repo_root / "kubernetes" / "infrastructure" / "monitoring" / "UPTIME_KUMA.md"
        ]
        
        for doc_path in monitoring_docs:
            if doc_path.exists():
                print(f"  ✓ {doc_path.name} exists")
                
                # Check for key sections
                with open(doc_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Look for common documentation sections
                if '##' not in content and '====' not in content:
                    self.warnings.append(f"{doc_path.name}: No section headers found")
                
                if 'Prerequisites' in content or 'Requirements' in content:
                    print(f"    ✓ Has prerequisites section")
                
                if 'Install' in content or 'Deploy' in content or 'Setup' in content:
                    print(f"    ✓ Has installation/setup section")
                
            else:
                self.errors.append(f"Missing documentation: {doc_path.name}")

    def test_yaml_code_blocks(self):
        """Test that YAML code blocks in documentation are valid."""
        print("\nTesting YAML code blocks in documentation...")
        md_files = self.get_markdown_files()
        
        import yaml
        
        for filepath in md_files:
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract YAML code blocks
                yaml_blocks = re.findall(r'```(?:yaml|yml)\n(.*?)```', content, re.DOTALL)
                
                for i, yaml_block in enumerate(yaml_blocks, 1):
                    try:
                        yaml.safe_load(yaml_block)
                    except yaml.YAMLError as e:
                        self.errors.append(f"{filepath.name}: Invalid YAML in code block {i}: {e}")
                
                if yaml_blocks:
                    print(f"  ✓ {filepath.name}: {len(yaml_blocks)} YAML code block(s) validated")
                
            except Exception as e:
                self.errors.append(f"{filepath.name}: Error validating YAML blocks: {e}")

    def test_shell_code_blocks(self):
        """Test that shell code blocks in documentation are syntactically valid."""
        print("\nTesting shell code blocks in documentation...")
        md_files = self.get_markdown_files()
        
        for filepath in md_files:
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract shell code blocks
                shell_blocks = re.findall(r'```(?:bash|sh|shell)\n(.*?)```', content, re.DOTALL)
                
                for i, shell_block in enumerate(shell_blocks, 1):
                    # Basic validation - check for common issues
                    lines = shell_block.strip().split('\n')
                    
                    for j, line in enumerate(lines, 1):
                        # Skip comments and empty lines
                        if line.strip().startswith('#') or not line.strip():
                            continue
                        
                        # Check for unclosed quotes
                        single_quotes = line.count("'") - line.count("\\'")
                        double_quotes = line.count('"') - line.count('\\"')
                        
                        if single_quotes % 2 != 0:
                            self.warnings.append(f"{filepath.name}: Possible unclosed single quote in shell block {i}, line {j}")
                        
                        if double_quotes % 2 != 0:
                            self.warnings.append(f"{filepath.name}: Possible unclosed double quote in shell block {i}, line {j}")
                
                if shell_blocks:
                    print(f"  ✓ {filepath.name}: {len(shell_blocks)} shell code block(s) checked")
                
            except Exception as e:
                self.errors.append(f"{filepath.name}: Error checking shell blocks: {e}")

    def test_url_validity(self):
        """Test that URLs in documentation follow best practices."""
        print("\nTesting URLs in documentation...")
        md_files = self.get_markdown_files()
        
        for filepath in md_files:
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Find all URLs
                urls = re.findall(r'https?://[^\s\)]+', content)
                
                for url in urls:
                    # Check for common issues
                    if url.endswith('.'):
                        self.warnings.append(f"{filepath.name}: URL ends with period: {url}")
                    
                    # Check for localhost URLs
                    if 'localhost' in url or '127.0.0.1' in url:
                        self.warnings.append(f"{filepath.name}: Contains localhost URL: {url}")
                
                if urls:
                    print(f"  ✓ {filepath.name}: {len(urls)} URL(s) checked")
                
            except Exception as e:
                self.errors.append(f"{filepath.name}: Error checking URLs: {e}")

    def run_all_tests(self):
        """Run all documentation tests and report results."""
        print("=" * 70)
        print("DOCUMENTATION TESTS")
        print("=" * 70)
        print()
        
        self.test_markdown_syntax()
        self.test_internal_links()
        self.test_code_blocks()
        self.test_documentation_completeness()
        self.test_yaml_code_blocks()
        self.test_shell_code_blocks()
        self.test_url_validity()
        
        print()
        print("=" * 70)
        print("TEST SUMMARY")
        print("=" * 70)
        
        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            for error in self.errors:
                print(f"  - {error}")
        
        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  - {warning}")
        
        if not self.errors and not self.warnings:
            print("\n✅ ALL TESTS PASSED!")
            return 0
        elif not self.errors:
            print(f"\n✅ ALL TESTS PASSED (with {len(self.warnings)} warnings)")
            return 0
        else:
            print(f"\n❌ TESTS FAILED: {len(self.errors)} error(s), {len(self.warnings)} warning(s)")
            return 1


if __name__ == "__main__":
    tester = TestDocumentation()
    sys.exit(tester.run_all_tests())