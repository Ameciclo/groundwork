#!/usr/bin/env python3
"""
Comprehensive test suite for the monitoring stack Kubernetes manifests.

Tests cover:
- YAML syntax validation
- Kubernetes resource schema validation
- Best practices and security checks
- Resource limits and requests validation
- Label consistency
- Configuration correctness
"""

import yaml
import sys
import os
from pathlib import Path
from typing import Dict, List, Any, Optional


class TestMonitoringStack:
    """Test suite for monitoring stack YAML manifests."""

    def __init__(self):
        self.repo_root = Path(__file__).parent.parent.parent.parent
        self.monitoring_path = self.repo_root / "kubernetes" / "infrastructure" / "monitoring"
        self.errors = []
        self.warnings = []

    def load_yaml_file(self, filepath: Path) -> List[Dict[str, Any]]:
        """Load and parse a YAML file, supporting multi-document files."""
        try:
            with open(filepath, 'r') as f:
                documents = list(yaml.safe_load_all(f))
                return [doc for doc in documents if doc is not None]
        except yaml.YAMLError as e:
            self.errors.append(f"YAML parse error in {filepath.name}: {e}")
            return []
        except Exception as e:
            self.errors.append(f"Error reading {filepath.name}: {e}")
            return []

    def test_yaml_syntax(self):
        """Test that all YAML files have valid syntax."""
        print("Testing YAML syntax...")
        yaml_files = list(self.monitoring_path.glob("*.yaml"))
        
        for filepath in yaml_files:
            docs = self.load_yaml_file(filepath)
            if docs:
                print(f"  ✓ {filepath.name}: Valid YAML syntax")
            else:
                print(f"  ✗ {filepath.name}: Invalid YAML syntax")

    def test_namespace_configuration(self):
        """Test namespace.yaml configuration."""
        print("\nTesting namespace configuration...")
        filepath = self.monitoring_path / "namespace.yaml"
        docs = self.load_yaml_file(filepath)
        
        if not docs:
            return
        
        namespace = docs[0]
        
        # Check apiVersion
        if namespace.get('apiVersion') != 'v1':
            self.errors.append("namespace.yaml: apiVersion should be 'v1'")
        else:
            print("  ✓ Correct apiVersion")
        
        # Check kind
        if namespace.get('kind') != 'Namespace':
            self.errors.append("namespace.yaml: kind should be 'Namespace'")
        else:
            print("  ✓ Correct kind")
        
        # Check metadata.name
        if namespace.get('metadata', {}).get('name') != 'monitoring':
            self.errors.append("namespace.yaml: namespace name should be 'monitoring'")
        else:
            print("  ✓ Correct namespace name")
        
        # Check labels
        labels = namespace.get('metadata', {}).get('labels', {})
        required_labels = ['name', 'app.kubernetes.io/name', 'app.kubernetes.io/managed-by']
        for label in required_labels:
            if label not in labels:
                self.warnings.append(f"namespace.yaml: Missing recommended label '{label}'")
            else:
                print(f"  ✓ Has label: {label}")

    def test_kustomization(self):
        """Test kustomization.yaml configuration."""
        print("\nTesting kustomization configuration...")
        filepath = self.monitoring_path / "kustomization.yaml"
        docs = self.load_yaml_file(filepath)
        
        if not docs:
            return
        
        kustomization = docs[0]
        
        # Check apiVersion
        if not kustomization.get('apiVersion', '').startswith('kustomize.config.k8s.io'):
            self.errors.append("kustomization.yaml: apiVersion should be kustomize.config.k8s.io/*")
        else:
            print("  ✓ Correct apiVersion")
        
        # Check kind
        if kustomization.get('kind') != 'Kustomization':
            self.errors.append("kustomization.yaml: kind should be 'Kustomization'")
        else:
            print("  ✓ Correct kind")
        
        # Check resources exist
        resources = kustomization.get('resources', [])
        if not resources:
            self.errors.append("kustomization.yaml: No resources defined")
        else:
            print(f"  ✓ {len(resources)} resources defined")
            
            # Verify all referenced files exist
            for resource in resources:
                resource_path = self.monitoring_path / resource
                if not resource_path.exists():
                    self.errors.append(f"kustomization.yaml: Referenced file '{resource}' does not exist")
                else:
                    print(f"    ✓ {resource} exists")
        
        # Check commonLabels
        if 'commonLabels' in kustomization:
            print("  ✓ commonLabels defined")
        else:
            self.warnings.append("kustomization.yaml: Consider adding commonLabels")

    def test_service_monitor(self):
        """Test ServiceMonitor configuration for Traefik."""
        print("\nTesting ServiceMonitor configuration...")
        filepath = self.monitoring_path / "traefik-servicemonitor.yaml"
        docs = self.load_yaml_file(filepath)
        
        if not docs:
            return
        
        sm = docs[0]
        
        # Check apiVersion
        if sm.get('apiVersion') != 'monitoring.coreos.com/v1':
            self.errors.append("ServiceMonitor: apiVersion should be 'monitoring.coreos.com/v1'")
        else:
            print("  ✓ Correct apiVersion")
        
        # Check kind
        if sm.get('kind') != 'ServiceMonitor':
            self.errors.append("ServiceMonitor: kind should be 'ServiceMonitor'")
        else:
            print("  ✓ Correct kind")
        
        # Check namespace
        namespace = sm.get('metadata', {}).get('namespace')
        if namespace != 'kube-system':
            self.warnings.append(f"ServiceMonitor: namespace is '{namespace}', traefik is typically in 'kube-system'")
        else:
            print("  ✓ Correct namespace")
        
        # Check selector
        if 'selector' not in sm.get('spec', {}):
            self.errors.append("ServiceMonitor: Missing selector in spec")
        else:
            print("  ✓ Selector defined")
        
        # Check endpoints
        endpoints = sm.get('spec', {}).get('endpoints', [])
        if not endpoints:
            self.errors.append("ServiceMonitor: No endpoints defined")
        else:
            print(f"  ✓ {len(endpoints)} endpoint(s) defined")
            
            for idx, endpoint in enumerate(endpoints):
                if 'port' not in endpoint:
                    self.errors.append(f"ServiceMonitor: Endpoint {idx} missing 'port'")
                if 'interval' in endpoint:
                    print(f"    ✓ Scrape interval: {endpoint['interval']}")
                if 'path' in endpoint:
                    print(f"    ✓ Metrics path: {endpoint['path']}")

    def test_traefik_metrics_service(self):
        """Test Traefik metrics Service configuration."""
        print("\nTesting Traefik metrics Service...")
        filepath = self.monitoring_path / "traefik-metrics-service.yaml"
        docs = self.load_yaml_file(filepath)
        
        if not docs:
            return
        
        service = docs[0]
        
        # Check apiVersion
        if service.get('apiVersion') != 'v1':
            self.errors.append("traefik-metrics-service: apiVersion should be 'v1'")
        else:
            print("  ✓ Correct apiVersion")
        
        # Check kind
        if service.get('kind') != 'Service':
            self.errors.append("traefik-metrics-service: kind should be 'Service'")
        else:
            print("  ✓ Correct kind")
        
        # Check type
        service_type = service.get('spec', {}).get('type')
        if service_type != 'ClusterIP':
            self.warnings.append(f"traefik-metrics-service: type is '{service_type}', ClusterIP is recommended for internal services")
        else:
            print("  ✓ Service type: ClusterIP")
        
        # Check ports
        ports = service.get('spec', {}).get('ports', [])
        if not ports:
            self.errors.append("traefik-metrics-service: No ports defined")
        else:
            print(f"  ✓ {len(ports)} port(s) defined")
            for port in ports:
                if port.get('name') == 'metrics':
                    print(f"    ✓ Metrics port: {port.get('port')}")
        
        # Check selector
        if 'selector' not in service.get('spec', {}):
            self.errors.append("traefik-metrics-service: Missing selector")
        else:
            print("  ✓ Selector defined")

    def test_grafana_ingress(self):
        """Test Grafana Ingress configuration."""
        print("\nTesting Grafana Ingress...")
        filepath = self.monitoring_path / "grafana-ingress.yaml"
        docs = self.load_yaml_file(filepath)
        
        if not docs:
            return
        
        ingress = docs[0]
        
        # Check apiVersion
        api_version = ingress.get('apiVersion')
        if not api_version or not api_version.startswith('networking.k8s.io'):
            self.errors.append("grafana-ingress: apiVersion should be 'networking.k8s.io/v1'")
        else:
            print("  ✓ Correct apiVersion")
        
        # Check kind
        if ingress.get('kind') != 'Ingress':
            self.errors.append("grafana-ingress: kind should be 'Ingress'")
        else:
            print("  ✓ Correct kind")
        
        # Check namespace
        if ingress.get('metadata', {}).get('namespace') != 'monitoring':
            self.errors.append("grafana-ingress: Should be in 'monitoring' namespace")
        else:
            print("  ✓ Correct namespace")
        
        # Check ingressClassName
        ingress_class = ingress.get('spec', {}).get('ingressClassName')
        if ingress_class == 'tailscale':
            print("  ✓ Using Tailscale ingress (private access)")
        else:
            self.warnings.append(f"grafana-ingress: ingressClassName is '{ingress_class}'")
        
        # Check TLS
        if 'tls' in ingress.get('spec', {}):
            print("  ✓ TLS configured")
        else:
            self.warnings.append("grafana-ingress: TLS not configured")
        
        # Check backend service
        backend = ingress.get('spec', {}).get('defaultBackend', {})
        if backend:
            service_name = backend.get('service', {}).get('name')
            if service_name:
                print(f"  ✓ Backend service: {service_name}")

    def test_uptime_kuma_deployment(self):
        """Test Uptime Kuma Deployment configuration."""
        print("\nTesting Uptime Kuma Deployment...")
        filepath = self.monitoring_path / "uptime-kuma-deployment.yaml"
        docs = self.load_yaml_file(filepath)
        
        if not docs:
            return
        
        # Find the Deployment document
        deployment = None
        service = None
        pvc = None
        
        for doc in docs:
            kind = doc.get('kind')
            if kind == 'Deployment':
                deployment = doc
            elif kind == 'Service':
                service = doc
            elif kind == 'PersistentVolumeClaim':
                pvc = doc
        
        # Test Deployment
        if deployment:
            print("  Testing Deployment...")
            
            # Check replicas
            replicas = deployment.get('spec', {}).get('replicas')
            if replicas == 1:
                print("    ✓ Replicas: 1 (correct for SQLite)")
            else:
                self.warnings.append(f"uptime-kuma: replicas is {replicas}, should be 1 for SQLite")
            
            # Check strategy
            strategy = deployment.get('spec', {}).get('strategy', {}).get('type')
            if strategy == 'Recreate':
                print("    ✓ Strategy: Recreate (correct for PVC)")
            else:
                self.errors.append("uptime-kuma: strategy should be 'Recreate' for PVC-backed app")
            
            # Check container spec
            containers = deployment.get('spec', {}).get('template', {}).get('spec', {}).get('containers', [])
            if containers:
                container = containers[0]
                
                # Check image
                image = container.get('image', '')
                if 'uptime-kuma' in image:
                    print(f"    ✓ Image: {image}")
                    # Check for version tag
                    if ':' in image and not image.endswith(':latest'):
                        print("    ✓ Versioned image (not :latest)")
                    else:
                        self.warnings.append("uptime-kuma: Consider using a specific version tag")
                
                # Check resource requests
                resources = container.get('resources', {})
                if 'requests' in resources:
                    print(f"    ✓ Resource requests: {resources['requests']}")
                else:
                    self.errors.append("uptime-kuma: Missing resource requests")
                
                # Check resource limits
                if 'limits' in resources:
                    print(f"    ✓ Resource limits: {resources['limits']}")
                else:
                    self.warnings.append("uptime-kuma: Missing resource limits")
                
                # Check probes
                if 'livenessProbe' in container:
                    print("    ✓ Liveness probe configured")
                else:
                    self.warnings.append("uptime-kuma: Missing liveness probe")
                
                if 'readinessProbe' in container:
                    print("    ✓ Readiness probe configured")
                else:
                    self.warnings.append("uptime-kuma: Missing readiness probe")
                
                # Check volume mounts
                volume_mounts = container.get('volumeMounts', [])
                if volume_mounts:
                    print(f"    ✓ {len(volume_mounts)} volume mount(s)")
                else:
                    self.errors.append("uptime-kuma: No volume mounts (data persistence required)")
        
        # Test Service
        if service:
            print("  Testing Service...")
            if service.get('spec', {}).get('type') == 'ClusterIP':
                print("    ✓ Service type: ClusterIP")
            
            ports = service.get('spec', {}).get('ports', [])
            if ports:
                print(f"    ✓ {len(ports)} port(s) exposed")
        
        # Test PVC
        if pvc:
            print("  Testing PersistentVolumeClaim...")
            storage = pvc.get('spec', {}).get('resources', {}).get('requests', {}).get('storage')
            if storage:
                print(f"    ✓ Storage request: {storage}")
            
            access_modes = pvc.get('spec', {}).get('accessModes', [])
            if 'ReadWriteOnce' in access_modes:
                print("    ✓ Access mode: ReadWriteOnce")

    def test_uptime_kuma_ingress(self):
        """Test Uptime Kuma Ingress configuration."""
        print("\nTesting Uptime Kuma Ingress...")
        filepath = self.monitoring_path / "uptime-kuma-ingress.yaml"
        docs = self.load_yaml_file(filepath)
        
        if not docs:
            return
        
        # Find Ingress and Middleware
        ingress = None
        middleware = None
        
        for doc in docs:
            kind = doc.get('kind')
            if kind == 'Ingress':
                ingress = doc
            elif kind == 'Middleware':
                middleware = doc
        
        # Test Ingress
        if ingress:
            print("  Testing Ingress...")
            
            # Check ingressClassName
            ingress_class = ingress.get('spec', {}).get('ingressClassName')
            if ingress_class == 'traefik':
                print("    ✓ Using Traefik ingress")
            else:
                self.warnings.append(f"uptime-kuma ingress: ingressClassName is '{ingress_class}'")
            
            # Check TLS annotations
            annotations = ingress.get('metadata', {}).get('annotations', {})
            if 'traefik.ingress.kubernetes.io/router.tls' in annotations:
                print("    ✓ TLS configured")
            
            if 'traefik.ingress.kubernetes.io/router.tls.certresolver' in annotations:
                cert_resolver = annotations['traefik.ingress.kubernetes.io/router.tls.certresolver']
                print(f"    ✓ Cert resolver: {cert_resolver}")
            
            # Check rate limiting middleware
            if 'traefik.ingress.kubernetes.io/router.middlewares' in annotations:
                print("    ✓ Rate limiting middleware configured")
            else:
                self.warnings.append("uptime-kuma ingress: Consider adding rate limiting")
            
            # Check rules
            rules = ingress.get('spec', {}).get('rules', [])
            if rules:
                for rule in rules:
                    host = rule.get('host')
                    if host:
                        print(f"    ✓ Host: {host}")
                        # Check if host looks like a valid domain
                        if '.' not in host:
                            self.warnings.append(f"uptime-kuma ingress: Host '{host}' doesn't look like a valid domain")
            else:
                self.errors.append("uptime-kuma ingress: No rules defined")
        
        # Test Middleware
        if middleware:
            print("  Testing Middleware...")
            
            if middleware.get('kind') == 'Middleware':
                print("    ✓ Correct kind")
            
            # Check rate limit configuration
            spec = middleware.get('spec', {})
            if 'rateLimit' in spec:
                rate_limit = spec['rateLimit']
                print(f"    ✓ Rate limit: {rate_limit.get('average')}/min, burst: {rate_limit.get('burst')}")
            else:
                self.errors.append("Middleware: Missing rateLimit configuration")

    def test_argocd_application(self):
        """Test ArgoCD Application configuration."""
        print("\nTesting ArgoCD Application...")
        filepath = self.repo_root / "kubernetes" / "environments" / "prod" / "monitoring-app.yaml"
        docs = self.load_yaml_file(filepath)
        
        if not docs:
            return
        
        app = docs[0]
        
        # Check apiVersion
        if app.get('apiVersion') != 'argoproj.io/v1alpha1':
            self.errors.append("monitoring-app.yaml: apiVersion should be 'argoproj.io/v1alpha1'")
        else:
            print("  ✓ Correct apiVersion")
        
        # Check kind
        if app.get('kind') != 'Application':
            self.errors.append("monitoring-app.yaml: kind should be 'Application'")
        else:
            print("  ✓ Correct kind")
        
        # Check namespace
        if app.get('metadata', {}).get('namespace') != 'argocd':
            self.errors.append("monitoring-app.yaml: Should be in 'argocd' namespace")
        else:
            print("  ✓ Correct namespace")
        
        # Check source
        source = app.get('spec', {}).get('source', {})
        if source:
            repo_url = source.get('repoURL')
            if repo_url:
                print(f"  ✓ Repo: {repo_url}")
            
            target_revision = source.get('targetRevision')
            if target_revision:
                print(f"  ✓ Target revision: {target_revision}")
            
            path = source.get('path')
            if path:
                print(f"  ✓ Path: {path}")
        else:
            self.errors.append("monitoring-app.yaml: Missing source configuration")
        
        # Check destination
        destination = app.get('spec', {}).get('destination', {})
        if destination:
            server = destination.get('server')
            namespace = destination.get('namespace')
            if server:
                print(f"  ✓ Destination server: {server}")
            if namespace == 'monitoring':
                print(f"  ✓ Destination namespace: {namespace}")
        else:
            self.errors.append("monitoring-app.yaml: Missing destination configuration")
        
        # Check syncPolicy
        sync_policy = app.get('spec', {}).get('syncPolicy', {})
        if sync_policy:
            if 'automated' in sync_policy:
                print("  ✓ Automated sync enabled")
                automated = sync_policy['automated']
                if automated.get('prune'):
                    print("    ✓ Prune enabled")
                if automated.get('selfHeal'):
                    print("    ✓ Self-heal enabled")
        else:
            self.warnings.append("monitoring-app.yaml: No sync policy defined")

    def test_label_consistency(self):
        """Test that labels are consistent across resources."""
        print("\nTesting label consistency...")
        yaml_files = list(self.monitoring_path.glob("*.yaml"))
        
        common_labels = {}
        
        for filepath in yaml_files:
            docs = self.load_yaml_file(filepath)
            for doc in docs:
                if not doc:
                    continue
                
                kind = doc.get('kind')
                name = doc.get('metadata', {}).get('name')
                labels = doc.get('metadata', {}).get('labels', {})
                
                app_name = labels.get('app.kubernetes.io/name')
                if app_name:
                    if app_name not in common_labels:
                        common_labels[app_name] = []
                    common_labels[app_name].append(f"{kind}/{name}")
        
        print(f"  Found {len(common_labels)} distinct app.kubernetes.io/name labels:")
        for app_name, resources in common_labels.items():
            print(f"    {app_name}: {len(resources)} resource(s)")

    def test_security_best_practices(self):
        """Test security best practices."""
        print("\nTesting security best practices...")
        
        # Check for privileged containers
        yaml_files = list(self.monitoring_path.glob("*.yaml"))
        
        for filepath in yaml_files:
            docs = self.load_yaml_file(filepath)
            for doc in docs:
                if not doc or doc.get('kind') != 'Deployment':
                    continue
                
                containers = doc.get('spec', {}).get('template', {}).get('spec', {}).get('containers', [])
                for container in containers:
                    security_context = container.get('securityContext', {})
                    
                    # Check for privileged mode
                    if security_context.get('privileged'):
                        self.warnings.append(f"{filepath.name}: Container running in privileged mode")
                    
                    # Check for runAsNonRoot
                    if security_context.get('runAsNonRoot') is False:
                        self.warnings.append(f"{filepath.name}: Container running as root")
        
        print("  ✓ Security best practices check complete")

    def run_all_tests(self):
        """Run all tests and report results."""
        print("=" * 70)
        print("MONITORING STACK KUBERNETES MANIFEST TESTS")
        print("=" * 70)
        print()
        
        self.test_yaml_syntax()
        self.test_namespace_configuration()
        self.test_kustomization()
        self.test_service_monitor()
        self.test_traefik_metrics_service()
        self.test_grafana_ingress()
        self.test_uptime_kuma_deployment()
        self.test_uptime_kuma_ingress()
        self.test_argocd_application()
        self.test_label_consistency()
        self.test_security_best_practices()
        
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
    tester = TestMonitoringStack()
    sys.exit(tester.run_all_tests())